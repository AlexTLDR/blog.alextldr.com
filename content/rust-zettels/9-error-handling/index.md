---
title: "Error handling: the ? operator and  when panic and unwrap are good"
date: 2026-05-07
draft: false
description: "Error handling"
tags:
- rust
- ? operator
- panic
- unwrap
- .expect()
---

## The ? operator

- as the `?` operator is something that involves a "Chain of command" or a "Series of Steps", let's use for this post **The Coffee Shop** theme
- the `?` operator is a short way to deal with `Result`, shorter than `match` and `if let`
- after anything that returns a `Result` you can add `?` . This will give what's inside the `Result` if `Ok` or pass the error back if it's `Err`
```rust
struct Coffee;

// 1. try to grind the beans
fn grind_beans(beans: &str) -> Result<String, String> {
    if beans == "empty" {
        Err("No beans left!".to_string())
    } else {
        Ok("Fine grounds".to_string())
    }
}

// 2. try to brew the coffee
fn brew(grounds: String) -> Result<Coffee, String> {
    if grounds == "coarse" {
        Err("Coffee is diluted".to_string())
    } else {
        Ok(Coffee)
    }
}

fn make_coffee(beans_status: &str) -> Result<Coffee, String> {
    // the ? means "give me the beans" or if there are no beans, return an error
    let grounds = grind_beans(beans_status)?;
    let cup = brew(grounds)?;
    Ok(cup) // if we reached this point, no error happened
}

fn main() {
    match make_coffee("empty") {
        Ok(_) => println!("Coffee is ready!"),
        Err(e) => println!("Refund issued: {}", e),
    }
}
```
- since `?` is so easy to use, can't we use it in the `grind_beans` and `brew` functions? The answer is no. The reason, there is nothing to *unwrap*. To use the `?`, we must call another function that returns a `Result` or `Option`. The `?` is a consumer
- speaking of `Option`, the `?` operator works with it too
- to better understand the power of `?` let's compare some error handling in Rust vs Go. By using `?` we have less verbosity
```rust
struct Breakfast;

fn grind_beans() -> Result<(), String> {
    Ok(())
}

fn brew_espresso() -> Result<(), String> {
    // let's pretend the machine breaks here
    Err("water pressure too low!".to_string())
}

fn steam_milk() -> Result<(), String> {
    Ok(())
}

// the chain of command
fn serve_breakfast() -> Result<Breakfast, String> {
    grind_beans()?;
    brew_espresso()?; // chain breaks here
    steam_milk()?;

    Ok(Breakfast)
}

fn main() {
    match serve_breakfast() {
        Ok(_) => println!("Enjoy your breakfast!"),
        Err(e) => println!("Oh no! {}", e),
    }
}
// prints
// Oh no! water pressure too low!
```

- now the same code in Go
```go
package main

import (
	"errors"
	"fmt"
)

type Breakfast struct{}

func grindBeans() error {
	return nil // Success
}

func brewEspresso() error {
	// The machine breaks here
	return errors.New("water pressure too low")
}

func steamMilk() error {
	return nil
}

// In Go, we have to check every single step manually.
func serveBreakfast() (*Breakfast, error) {
	err := grindBeans()
	if err != nil {
		return nil, err
	}

	err = brewEspresso()
	if err != nil {
		// We stop here, but it took 3 lines of code to do it.
		return nil, err
	}

	err = steamMilk()
	if err != nil {
		return nil, err
	}

	return &Breakfast{}, nil
}

func main() {
	breakfast, err := serveBreakfast()
	if err != nil {
		fmt.Printf("Oh no! %s\n", err)
		return
	}
	fmt.Println("Here is your breakfast!", breakfast)
}
// prints
// Oh no! water pressure too low
```

## When panic and unwrap are good

- if we write the below program, Rust will panic
```rust
fn main() {
    panic!();
}
```
- the output
```bash
❯ cargo run
   Compiling tmp v0.1.0 (/var/home/alex/github.com/tmp_stuff/rust/tmp)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.08s
     Running `target/debug/tmp`

thread 'main' (49984) panicked at src/main.rs:2:5:
explicit panic
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
```

- it is good to use `panic!` when our program hits an unrecoverable or impossible state that makes it dangerous or logically useless to continue
```rust
fn brew_espresso(pressure: i32) -> Result<(), String> {
    if pressure < 5 {
        // this is a recoverable error. 
        // the barista can just check the seals and try again.
        return Err("Pressure too low, check the water tank.".to_string());
    }

    if pressure > 100 {
        // panic! The machine is about to explode.
        // continuing to run the code is dangerous.
        panic!("Pressure at {} PSI. Shutting down the machine!", pressure);
    }

    println!("Perfect extraction at {} PSI.", pressure);
    Ok(())
}

fn main() {
    // this will return an Err we can handle
    let _ = brew_espresso(2);

    // this will trigger the panic and kill the program immediately
    let _ = brew_espresso(500);
}
// prints
// thread 'main' (51762) panicked at src/main.rs:11:9:
// Pressure at 500 PSI. Shutting down the machine!
// note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
```

- `panic!` along `assert!`, `assert_eq!` and `assert_ne!` are used a lot in testing. For example you work on a banking app and define the card number in `Vec`. The card numbers are always 16 characters so the `Vec` needs to always be 16 chars long. You can:
```rust
if vector.len() != 16 {
        panic!("card_vec must always have 16 items");
    }
```

- `assert!` will panic if the part inside `()` is not true
- `assert_eq!` will panic if the 2 items inside the `()` are not equal
- `assert_ne!` opposite to `assert_eq!`.  ne means not equal 

## .expect()

- `.unwrap()` and `.expect()` are both "lazy" ways to handle a `Result`. Keeping the theme, they both say: *"Give me the coffee inside this package, and if it's empty, just crash the whole shop"* 
- using `.unwrap()` (The Silent Crash)
```rust
let milk = fridge.get_milk().unwrap();
```
- if the fridge is empty, the program panics with a generic message: `thread 'main' panicked at 'called Option::unwrap() on a None value'`
- in a large code base, this can be hard to debug
- using `.expect()` (The Helpful Crash)
```rust
let milk = fridge.get_milk().expect("CRITICAL: The milk delivery didn't arrive!");
```
- now, if the fridge is empty, the panic message looks like this: `thread 'main' panicked at 'CRITICAL: The milk delivery didn't arrive!'` 
- with `.expect()` we see exactly where the error is, which is helpful in a large code base

---  
🦀 In the next post, we will learn about traits (for my gopher readers, Rust's interfaces)
