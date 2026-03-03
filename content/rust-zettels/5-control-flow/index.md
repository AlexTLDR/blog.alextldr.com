---
title: "Control flow"
date: 2026-03-03
draft: false
description: "Control flow in Rust."
tags:
- rust
- if
- else if
- else
- match
- loop
- for
- while
- range
---
# Control flow

- in Rust as in most of the programming languages, code runs from top to bottom, one line at a time
- at a point, the program execution will run into a fork in the road and will need to choose a path based on a condition
- in Rust usually it will be an `if` or a `match statement` . An analogy will be, *if it is raining, take an umbrella, otherwise wear sun glasses*
- loops are also part of the control flow. A loop is similar to the live situation; *keep running laps until you have finished 5 km*
- control flow is important, as without it, software would be "static." You couldn't have a login screen (selection), you couldn't process a list of 1,000 emails (iteration), and you couldn't handle errors (decision making). Control flow is what transforms a static list of data into a **dynamic application**

## Basic control flow

- the simplest form is the `if` statement followed by the code block `{}`
- `=` is used for assignment, and `==` is used for comparison 
```rust
fn main() {  
   let name = String::from("John");  
   if name == "Alex" {  
      println!("Hello Alex");  
   }  
}
// doesn't print anything as the
// if condition is not met
```
- `else if` and `else` are used for more control of the flow
```rust
fn main() {  
   let name = String::from("John");  
   if name == "Alex" {  
      println!("Hello Alex");  
   } else if name == "John" {  
      println!("Hello John");  
   } else {  
      println!("Hello unknown hero");  
   }  
}
// Hello John
```
- in the above flow, `name = String::from("John")` . Then the program evaluates `if name == "Alex"` . It is not so it jumps to the next *arm*. `else if name == "John"` evaluates to true, so it runs the code between the curly brackets, `println!("Hello John")`
- if it was `name = String::from("Jane")`, the flow of execution would have checked `if name == "Alex"`, evaluate it to false, check `else if name == "John"` evaluate it to false and executed the default arm, the else => `println!("Hello unknown hero")`
- an arm can have more conditions, like `&&` and `||`
- `&&` = and
- `||` = or
```rust
fn main() {  
   let number = 15;  
   if number % 3 == 0 && number % 5 == 0 {  
      println!("fizzbuzz");  
   } else if number % 3 == 0 {  
      println!("fizz");  
   } else if number % 5 == 0 {  
      println!("buzz");  
   } else {  
      println!("{}", number);  
   }  
}
// fizzbuzz
```

## Match statements

- if statements are fine, but they are harder to read. Like in Go, where it is idiomatic to use if statements mostly for error handling and switch for more complex control flows, in Rust we have `match`
- when using `match` , Rust wants you to cover all the arms
- so `else`, which is the default arm, is noted with an `_` 
```rust
fn main() {  
    let season = String::from("fall");  
    match season.as_str() {  
        "spring" => println!("spring"),  
        "summer" => println!("summer"),  
        "fall" => println!("fall"),  
        "winter" => println!("winter"),  
    }  
}
```
- this errors
```bash
cargo run
   Compiling tmp v0.1.0 (/home/alex/github.com/tmp_stuff/rust/tmp)
error[E0004]: non-exhaustive patterns: `&_` not covered
 --> src/main.rs:3:11
  |
3 |     match season.as_str() {
  |           ^^^^^^^^^^^^^^^ pattern `&_` not covered
  |
  = note: the matched value is of type `&str`
  = note: `&str` cannot be matched exhaustively, so a wildcard `_` is necessary
help: ensure that all possible cases are being handled by adding a match arm with a wildcard pattern or an explicit pattern as shown
  |
7 ~         "winter" => println!("winter"),
8 ~         &_ => todo!(),
  |

For more information about this error, try `rustc --explain E0004`.
error: could not compile `tmp` (bin "tmp") due to 1 previous error
```
- to solve the error, we must include the *default* arm
```rust
fn main() {  
    let season = String::from("autumn");  
    match season.as_str() {  
        "spring" => println!("spring"),  
        "summer" => println!("summer"),  
        "fall" => println!("fall"),  
        "winter" => println!("winter"),  
        _ => println!("not a season"),  
    }  
}
// not a season
```
- TLDR for `match` statements:
	- after `match` comes the name of the item that you match against
	- on the left is the pattern, and on the right of the fat arrow `=>` is the instruction if the pattern matches
	- as already mentioned, each line is called an *arm*
	- arms are delimited by commas and not semicolons
- `match` can be used for declaring variables as well
```rust
fn main() {  
    let my_name = "Alex";  
    let full_name = match my_name {  
        "John" => "John Doe",  
        "Jane" => "Jane Doe",  
        "Alex" => "AlexTLDR",  
        _ => "Unknown",  
    };  
    println!("Hello, {}", full_name);  
}
// Hello, AlexTLDR
```
- `match` can be used on more complicated patterns, like tuples
```rust
fn main() {  
    let language = "Go";  
    let difficulty = "medium";  
  
    match (language, difficulty) {  
        ("Rust", "easy") => println!("Rust is easy to learn"),  
        ("Go", "medium") => println!("Go is fun to learn"),  
        ("Python", "meh") => println!("Python is meh to learn"),  
        _ => println!("Depends"),  
    }  
}
// Go is fun to learn
```
- a **match guard** is an extra `if` in the `match` arm. It allows you to filter a pattern based on the value of the data, not just the structure 
```rust
fn main() {  
    let language = "Go";  
    let happy = true;  
  
    match (language, happy) {  
        (language, happy) if language == "Rust" && happy => println!("I am happy to learn Rust"),  
        (language, happy    ) if language == "Go" && happy => println!("I am happy to learn Go"),  
        (language, _) if language == "Python" => println!("I don't want to learn Python"),  
        _ => println!("Depends"),  
    }  
}
// I am happy to learn Go
```
- in the above, we used `&& happy` instead of `&& happy = true` . `&& happy = false` is written `&& !happy` . As in Go,  bang `!` is used as *not*, like `==` or `!=`  
- in the Python arm, we used `_` to ignore the happy bool. In a bigger tuple, let's say with 5 elements, we could have used `_` 4 times, to ignore 4 of the elements 
- each arm of a `match` must return the same type
- but if we use `if` and `else` we can bypass this. Because `if` and `else` have their own execution blocks `{}` this means they have separate scopes. As a value lives and dies in its scope, the below code is correct and compiles
```rust
fn main() {  
    let language = "Go";  
  
    if language == "Go" {  
        let first_language = "Go";  
    } else {  
        let first_language = 0;  
    }  
}
```
- the compiler complains about unused variables, but it compiles
```bash
cargo run
   Compiling tmp v0.1.0 (/home/alex/github.com/tmp_stuff/rust/tmp)
warning: unused variable: `first_language`
 --> src/main.rs:5:13
  |
5 |         let first_language = "Go";
  |             ^^^^^^^^^^^^^^ help: if this is intentional, prefix it with an underscore: `_first_language`
  |
  = note: `#[warn(unused_variables)]` (part of `#[warn(unused)]`) on by default

warning: unused variable: `first_language`
 --> src/main.rs:7:13
  |
7 |         let first_language = 0;
  |             ^^^^^^^^^^^^^^ help: if this is intentional, prefix it with an underscore: `_first_language`

warning: `tmp` (bin "tmp") generated 2 warnings (run `cargo fix --bin "tmp" -p tmp` to apply 2 suggestions)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.09s
     Running `target/debug/tmp`
```
- if you want to give a name to the value of a match expression, use `@`. In the below example, we are using `y` instead of `year`
```rust
fn classify_language(year: i32, name: &str) {  
    match year {  
        y @ 1972 => println!("{name} was born in {y}. The C era begins!"),  
        y @ 1990..=1995 => println!("{name} ({y}) belongs to the World Wide Web boom."),  
        y @ 2009 => println!("{name} was born in {y}. The Google/Go era begins!"),  
        y if y >= 2010 => println!("{name} ({y}) is a modern-era language!"),  
        _ => println!("{name} was released in {year}."),  
    }  
}  
  
fn main() {  
    classify_language(1972, "C");  
    classify_language(1991, "Python");  
    classify_language(2009, "Go");    // Hits the new 2009 arm  
    classify_language(2015, "Rust");  // Hits the >= 2010 guard  
}
// C was born in 1972. The C era begins!
// Python (1991) belongs to the World Wide Web boom.
// Go was born in 2009. The Google/Go era begins!
// Rust (2015) is a modern-era language!
```
- for me this was confusing, but it has a great use when we want **to give a name to a value and simultaneously test it against a pattern**

## Loops
- in most programming languages, loops are used to repeat an action until a certain condition is matched and the loop stops. A loop can run indefinitely if it doesn't have a stop condition
```rust
fn main() {
    loop {}
}
```
- by using a start point and an end point, we can control the flow of the loop
```rust
use std::thread;    
use std::time::Duration;  
fn main() {  
   let mut counter = 10;   
    loop {  
        if counter == 0 {  
            println!{"Blast off!"};  
            break;  
        }  
        println!("{counter}");  
        thread::sleep(Duration::from_secs(1));  
        counter -= 1;  
    }  
}
```
- in the above code, the starting point of our blast-off script is `let mut counter = 10` and the stop condition is `if counter == 0`. When we reach 0, we `break` . Ignore for now the `use` statements at the beginning (we will cover `use` in a later blog post). Those are used to import the `sleep` that we used to wait one second for each iteration of the `loop` 
- this will print:
```bash
cargo run
   Compiling tmp v0.1.0 (/home/alex/github.com/tmp_stuff/rust/tmp)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.08s
     Running `target/debug/tmp`
10
9
8
7
6
5
4
3
2
1
Blast off!
```
- like in other languages, we will use nested loops (a loop within a loop). To make it easier to track these loops, we can name each loop by using the tick symbol `'` . The syntax is `'label: loop {}`
```rust
fn main() {  
    let mut year = 0;  
    let mut century = 0;  
    let mut millennium = 0;  
  
    // Notice the syntax: 'label: loop  
    'outer_millennium: loop {  
        millennium += 1;  
  
        'mid_century: loop {  
            century += 1;  
  
            'inner_year: loop {  
                year += 1;  
  
                if year % 100 == 0 {  
                    println!("Century {century} reached in millennium {millennium}!");  
                    // We break the INNER loop to move to the next century logic  
                    break 'inner_year;  
                }  
  
                if millennium == 3 && century == 21 && year == 2026 {  
                    println!("Target date reached: {year} AD. Stopping all clocks!");  
                    // This is the power of labels: Breaking the TOP-LEVEL loop from here.  
                    break 'outer_millennium;  
                }  
            }  
  
            if century % 10 == 0 {  
                // Move to next millennium  
                break 'mid_century;  
            }  
        }  
    }  
}
```
- this is not the most readable code; it is only for demonstration purposes and it prints the below:
```bash
cargo run
   Compiling tmp v0.1.0 (/home/alex/github.com/tmp_stuff/rust/tmp)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.12s
     Running `target/debug/tmp`
Century 1 reached in millennium 1!
Century 2 reached in millennium 1!
Century 3 reached in millennium 1!
Century 4 reached in millennium 1!
Century 5 reached in millennium 1!
Century 6 reached in millennium 1!
Century 7 reached in millennium 1!
Century 8 reached in millennium 1!
Century 9 reached in millennium 1!
Century 10 reached in millennium 1!
Century 11 reached in millennium 2!
Century 12 reached in millennium 2!
Century 13 reached in millennium 2!
Century 14 reached in millennium 2!
Century 15 reached in millennium 2!
Century 16 reached in millennium 2!
Century 17 reached in millennium 2!
Century 18 reached in millennium 2!
Century 19 reached in millennium 2!
Century 20 reached in millennium 2!
Target date reached: 2026 AD. Stopping all clocks!
```
- `break` can be used to return values
```rust
fn main() {  
    let mut counter = 0;  
    let n = loop {  
        counter += 1;  
        if counter % 5 == 2 {  
            break counter;  
        }  
    };  
    println!("n = {n}");  
}
// n = 2
```
- the next loop is the `while` loop. The `while` loop continues `while` the condition is still `true` . On every iteration, Rust will check if the condition is `true` and will stop the loop when the condition is `false`
```rust
const YEAR: i32 = 2026;  
fn main() {  
   let mut year_counter = 2020;  
    while year_counter <= YEAR {  
        println!("{}", year_counter);  
        year_counter += 1;  
    }  
}
// 2020
// 2021
// 2022
// 2023
// 2024
// 2025
// 2026
```
- there is also the `for` loop. This loop works a little differently. It lets you tell Rust what to do each time, and it stops after a certain number of times, instead of checking if a condition is `true` or `false`
- for loops use ranges. `..` , which we already used previously, like in the `match` example with the years and programming languages
- `..` it is used for exclusive ranges -> `0..3` gives `0, 1, 2`
- and `..=` is for inclusive ranges -> `0..=3` gives `0, 1, 2, 3`
```rust
fn main() {  
    for n in 0..3 {  
        println!("// the exclusive for number is {n}")  
    }  
  
    for n in 0..=3 {  
        println!("// the inclusive for number is {n}")  
    }  
}
// the exclusive for number is 0
// the exclusive for number is 1
// the exclusive for number is 2
// the inclusive for number is 0
// the inclusive for number is 1
// the inclusive for number is 2
// the inclusive for number is 3
```
- if you don't use a variable name, the loop still works
```rust
fn main() {  
    for _ in 0..3 {  
        println!("// printing the same thing")  
    }  
}
// printing the same thing
// printing the same thing
// printing the same thing
```

---  
🦀 In the next post, we will cover structs and enums (something that is not available in Go 😢)
