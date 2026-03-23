---
title: "Generics, option and result"
date: 2026-03-23
draft: false
description: "Generics, option and result."
tags:
- rust
- structs
- enums
- methods
- Option
- Result
- if let
- let else
- while let
---

# Generics, option and result

Rust is a strict language that thrives on concrete types. But in this post, we will dive into 3 powerful tools that make this strictness work for us:

- **Generics** allow us to describe *some sort of type* to the compiler. It acts as a placeholder that Rust fills later with a concrete type only when the code is actually used
- **Option** is the *maybe* enum. It gives us a safe and explicit way to tell Rust what to do when a value might be missing, eliminating the *nil* errors found in `Go` for example
- **Result** is the *safety net* enum. It is the way Rust handles the *sad path*. Instead of crashing, `Result` forces us to decide what happens when an operation (like opening a file) fails

## Generics

- we already know that Rust needs to know the concrete types for the inputs and outputs of functions. For example, if we want to write a coordinate struct that can accept integers or floats, we can write it like so:
```rust
struct Point<T> {  
    x: T,  
    y: T,  
}  
  
fn main() {  
    let integer_point = Point { x: 5, y: 10 };  
    let float_point = Point { x: 3.14, y: 2.718 };  
    println!("Integer Point: ({}, {})", integer_point.x, integer_point.y);  
    println!("Float Point: ({}, {})", float_point.x, float_point.y);  
}
// prints
// Integer Point: (5, 10)
// Float Point: (3.14, 2.718)
```
- from the above example, for using `generics`, instead of the type, we use the angle brackets and a T notation, like `<T>`. This means *any type*. 
- idiomatic, rustaceans use one capital letter for `generics`, but technically the name doesn't matter. The only part that tells Rust that this is a generic type, are the angle brackets `<>`
- **just wanted to write this in bold, idiomatic Rust is** `<T>` 
```rust
use std::fmt::Display;  
  
// Read this as: "T is any type THAT implements Display"  
fn print_generic<T: Display>(item: T) {  
    println!("The item to print is: {}", item);  
}  
  
fn main() {  
    print_generic(5);  
    print_generic("Hello, world!");  
}
// prints
// The item to print is: 5
// The item to print is: Hello, world!
```
- in the above example we use `<T: Display>` which means any type that implements the `Display` trait
- `<T: Display>` is a `trait bond`. It is like a contract. We are promising to the compiler that we are plugging in only types that "speak the Display language" 
- the below code does the same thing as the above one, but it is used to illustrate the non-idiomatic way of writing generics. Because of the angle bracket, in the both examples, Rust doesn't care if we use `<T>` or `<PrintItem>`
```rust
use std::fmt::Display;  
  
// Read this as: "PrintItem is any type THAT implements Display"  
fn print_generic<PrintItem: Display>(item: PrintItem) {  
    println!("The item to print is: {}", item);  
}  
  
fn main() {  
    print_generic(5);  
    print_generic("Hello, world!");  
}
```
- following this principle, we should be able to create structs and give them `Display` with `#[derive(Display)]` . But in Rust we can't use `[derive(Display)]` as this is intended for the users, while `Debug` is intended for the developer and it can be generated automatically by the compiler
- **the compiler is happy to guess what a developer wants to see (Debug) but it refuses to guess what a human user should see(Display)**
- if Rust had like Go, [a list of proverbs](https://go-proverbs.github.io/), the above should be one of them
- below is an example derived from the `print_generic` function in which we integrate a struct as an *any type*
```rust
use std::fmt::Debug;  
  
#[derive(Debug)]  
struct Player {  
    name: String,  
    goals: i32,  
}  
  
fn print_generic_debug<T: Debug>(item: T) {  
    println!("The item to print is: {:?}", item);  
}  
  
fn main() {  
    let goat = Player {  
        name: String::from("Messi"),  
        goals: 755,  
    };  
    print_generic_debug(goat);  
    // printing non-Player types  
    print_generic_debug(5);  
    print_generic_debug("Hello");  
}
// prints
// The item to print is: Player { name: "Messi", goals: 755 }
// The item to print is: 5
// The item to print is: "Hello"
```
- we can also use multiple `generic` types in a function
- to achieve this, we need to write out each generic type name
- a generic type can hold more than one trait
- to add traits to a generic type, we add them with the `+` symbol like in the below example
```rust
use std::fmt::{Debug, Display};  
  
#[derive(Debug)]  
struct Player {  
    name: String,  
    goals: i32,  
}  

// using + to add 2 traits to the generic U type  
fn compare_and_display<T: Display, U: Display + PartialOrd>(statement: T, stat_1: U, stat_2: U) {  
    if stat_1 > stat_2 {  
        println!("{} {} is greater than {}", statement, stat_1, stat_2);  
    } else if stat_1 < stat_2 {  
        println!("{} {} is less than {}", statement, stat_1, stat_2);  
    } else {  
        println!("{} {} is less than {}", statement, stat_1, stat_2);  
    }  
}  
  
fn print_generic_debug<T: Debug>(item: T) {  
    println!("The item to print is: {:?}", item);  
}  
  
fn main() {  
    let goat = Player {  
        name: String::from("Messi"),  
        goals: 755,  
    };  
    print_generic_debug(goat);  
    // printing non-Player types  
    print_generic_debug(5);  
    print_generic_debug("Hello");  
  
    println!("--- Comparing goals ---");  
    compare_and_display("Goals Comparison", 821, 807);  
  
    // T is a String object, U is a float (f64)  
    let msg = String::from("Ballon d'Or Average");  
    compare_and_display(msg, 7.5, 8.2);  
}
// prints
// The item to print is: Player { name: "Messi", goals: 755 }
// The item to print is: 5
// The item to print is: "Hello"
// --- Comparing goals ---
// Goals Comparison 821 is greater than 807
// Ballon d'Or Average 7.5 is less than 8.2
```
- the generic type `U` implements the `PartialOrd` trait that we used for arithmetic operations like `<, <=, ==, => and >`
- if we have many generic types in a function, a good practice is to use the `where` key word
```rust
fn compare_and_display<T, U>(statement: T, stat_1: U, stat_2: U)  
where  
    T: Display,  
    U: Display + PartialOrd,  
{  
    if stat_1 > stat_2 {  
        println!("{} {} is greater than {}", statement, stat_1, stat_2);  
    } else if stat_1 < stat_2 {  
        println!("{} {} is less than {}", statement, stat_1, stat_2);  
    } else {  
        println!("{} {} is less than {}", statement, stat_1, stat_2);  
    }  
}
```

## Option and Result

In Rust, we categorize data based on how "certain" it is. Think of it like a football scout’s report:
- **`Option<T>` (The "Maybe" Stat):** Imagine a `Player` struct. Every player has a name, but not every player has an `Option<WorldCupTrophy>`.   
    - If the player is **Messi**, the value is `Some(Trophy)`.
    - If the player hasn't won it yet, the value is `None`.
    - **Crucial Point:** `None` isn't an error or a crash; it’s just a valid state of a player's career. It simply means the "World Cup" slot in their backpack is currently empty.
- **`Result<T, E>` (The "Match Day" Outcome):** Now imagine a function called `take_penalty()`. This isn't a static stat; it’s an **action** that can fail.
    - **`Ok(Goal)`**: The happy path. The ball hits the net.
    - **`Err(Missed)`**: The "sad path." Maybe the keeper saved it, or it hit the post.
    - Unlike an `Option`, a `Result` tells you **why** the action failed (the Error), so you can decide whether to try again or change tactics.    
- **Standard Functions (The "Guarantees"):** Simple functions like `get_player_name()` or `calculate_age()` don't need these. A player always has a name and an age. If the data is guaranteed to be there and the logic can't break, we don't bother with the "safety envelopes" of Option or Result.

### Option

- we use `Option` when something might or might not exist. If it exists, it is `Some(value)` and when it doesn't exist, it is `None`
- keeping the football examples in mind, let's write a program that prints when the referee blows the final whistle in the match
- in the below we didn't pay attention and when we declared the vector and it is not printing the expected `The match ended at minute: 90`
```rust
fn get_final_minute(minute: Vec<i32>) -> i32 {  
    minute[90]  
}  
  
fn main() {  
    let match_timeline = (1..=90).collect();  
    let whistle_blown_at = get_final_minute(match_timeline);  
    println!("The match ended at minute: {}", whistle_blown_at);  
}
```
- instead it prints:
```bash
thread 'main' (67537) panicked at src/main.rs:2:11:
index out of bounds: the len is 90 but the index is 90
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
```
- I hope that if you followed the initial posts, it is clear that index 0 is 1 and the 90th item is at index 89. Since function `get_final_minute` returns a *hard-coded* value of 90, the index is out of bounds
- we can "resolve" this issue by hard-codding the length of the `match_timeline` to (1..=91) but this will print `The match ended at minute: 91` so not really the expected resolution of `The match ended at minute: 90` or we can be more elegant using the flexible `Option<i32>'
```rust
fn get_final_minute(minute: Vec<i32>) -> Option<i32> {  
    // .get() returns Option<&i32>.  
    // We use .copied() to turn the reference into a plain i32.    
    minute.get(90).copied()  
}  
  
fn main() {  
    let match_timeline = (1..=90).collect();  
    let whistle_blown_at = get_final_minute(match_timeline);  
    match whistle_blown_at {  
        Some(minute) => println!("Whistle blown at minute: {}", minute),  
        None => println!("Match not finished"),  
    }  
}
// prints
// Match not finished
```
- this example is not yet functional as if we go `match_timeline = (1..=91)` or `match_timeline = (1..=95)` we get the same `Whistle blown at minute: 91` because `minute.get(90).copied()` hard-codes the value 90
- to fix this, we need to change `get_final_minute`'s signature to use `Option` and to write a helper function `print_match_end` that implements the `Some` and `None` match
```rust
fn get_final_minute(minute: &Vec<i32>) -> Option<i32> {  
    // .last() returns an Option<&i32> (Some if the Vec has items, None if empty)  
    // We use .copied() to turn the reference into a plain i32.    
    minute.last().copied()  
}  
  
fn print_match_end(label: &str, timeline: &Vec<i32>) {  
    match get_final_minute(timeline) {  
        Some(minute) => println!("{}: {}", label, minute),  
        None => println!("{}: Match not finished", label),  
    }  
}  
  
fn main() {  
    let regular_match = (1..=90).collect();  
    print_match_end("Regular Match", &regular_match);  
  
    let long_match = (1..=95).collect();  
    print_match_end("Stoppage Time Match", &long_match);  
  
    let cancelled_match = vec![];  
    print_match_end("Cancelled Match", &cancelled_match);  
  
}
// prints
// Regular Match: 90
// Stoppage Time Match: 95
// Cancelled Match: Match not finished
```
- while `match` is the safe way to handle an **Option**, `.unwrap()` is the "I am feeling lucky button". When using it, we are basically telling Rust, "I am 100% sure there is a value inside. If I'm wrong, just panic"
```rust
fn get_final_minute(minutes: &Vec<i32>) -> Option<i32> {  
    minutes.last().copied()  
}  
  
fn main() {  
    let match_95 = vec![1,2,3,94,95];  
    let last_min = get_final_minute(&match_95).unwrap();  
    println!("Last minute: {:?}", last_min);  
  
    let cancelled_match:Vec<i32> = vec![];  
    println!("Attempting to unwrap a cancelled match..");  
  
    let failed_min = get_final_minute(&cancelled_match).unwrap();  
    println!("This will never print because it will panic: {:?}", failed_min);  
}
// prints
// Last minute: 95
// Attempting to unwrap a cancelled match..
//
// thread 'main' (107007) panicked at src/main.rs:13:57:
// called `Option::unwrap()` on a `None` value
// note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
```
- using the same code, but without `.unwrap()`
```rust
fn get_final_minute(minutes: &Vec<i32>) -> Option<i32> {  
    minutes.last().copied()  
}  
  
fn main() {  
    let match_95 = vec![1,2,3,94,95];  
    let last_min = get_final_minute(&match_95);  
    println!("Last minute: {:?}", last_min);  
  
    let cancelled_match:Vec<i32> = vec![];  
    println!("Attempting to unwrap a cancelled match..");  
  
    let failed_min = get_final_minute(&cancelled_match);  
    println!("This will never print because it will panic: {:?}", failed_min);  
}
// prints
// Last minute: Some(95)
// Attempting to unwrap a cancelled match..
// This will never print because it will panic: None
```
- the difference is that by using `.unwrap()` we are telling Rust to extract the values from `Option` . So in the first example, it panics because the `None` has no value
- in the second example, Rust doesn't panic, as it simply prints `Some` and `None` without caring that `None` is empty. 
- in the first example, you are the receiver of the mail. You just received 2 envelopes and you extract the letters. In the `Some` envelope there is a letter, but the `None` envelope is empty, and you panic
- in the second example you are the mail man, and you just deliver 2 envelopes, `Some` and `None` without caring what is inside the envelopes
- to make your code cleaner, we can move the "decision-making" logic into a helper function. This separates the **getting** of the data from the **handling** of the data
```rust
fn get_final_minute(minutes: &Vec<i32>) -> Option<i32> {  
    minutes.last().copied()  
}  
  
fn handle_match_result(result: Option<i32>) {  
    match result {  
        Some(min) => println!("Match ended at minute: {}", min),  
        None => println!("Match was cancelled"),  
    }  
}  
  
fn main() {  
    let match_95 = vec![1,2,3,94,95];  
    let last_min = get_final_minute(&match_95);  
    handle_match_result(last_min);  
  
    let cancelled_match:Vec<i32> = vec![];  
    let canceled = get_final_minute(&cancelled_match);  
    handle_match_result(canceled);  
}
// prints
// Match ended at minute: 95
// Match was cancelled
```
- this is a good example of *pattern matching*, where `Some(number)` is a pattern and `None` is another pattern. By using `match`, we decide what to do when a pattern happens. This is how `Option` functions, with only 2 "routes" in which we have to decide what happens
- so the `Option` type is just an `enum`
```rust
enum Option<T> {
    None,
    Some(T),
}
```
- continuing with the football analogy, think of `Option<T>` as a trophy cabinet. The `<T>` is a **Generic**, which means this cabinet is designed to hold **"any kind of trophy"**—a Golden Boot, a World Cup, or a local league medal. Rust doesn't care what the trophy is, as long as it fits the "T" shape
	- **`Some(trophy)`**: The cabinet is occupied. You have the actual item (the value of type `T`) in your hands
	- **`None`**: The cabinet is empty. There is no trophy, no data, and no "T"
- there are easier ways to use `Option`
```rust
fn main() {  
    let striker = Some("Zlatan");  
    let defender: Option<&str> = None;  
  
    // .is_some() checks if the locker is OCCUPIED  
    if striker.is_some() {  
        println!("We have Zlatan on the pitch!");  
    }  
  
    // .is_none() checks if the locker is EMPTY  
    if defender.is_none() {  
        println!("Warning: No defender wants to play against Zlatan!");  
    }  
}
// prints
// We have Zlatan on the pitch!
// Warning: No defender wants to play against Zlatan!
```
- here we are using the `.is_some()` and `.is_none()` methods which as their names implies, they are telling Rust if there is some value or no (none) value
- coming from Go, I am used to more verbosity when it comes to error handling. When something fails, I am used to something like below (I know that the penalty was missed because Zlatan didn't execute it)
```go
package main

import (
	"errors"
	"fmt"
)

// in Go, we return (Value, Error)
func takePenalty(player string) (string, error) {
	if player == "Zlatan" {
		return "GOAL!", nil
	}
	// we return an empty string and a specific error
	return "", errors.New("keeper saved it")
}

func main() {
	// we are keeping track of both the Value and the Error
	score, err := takePenalty("Messi")

	// the error handling Go verbosity: "if err != nil"
	if err != nil {
		fmt.Println("Penalty Missed:", err)
		return 
	}
	fmt.Println(score)
}
// prints
// Penalty Missed: keeper saved it
```
- in Rust, we can do something similar with `Result`

### Result

```rust
fn take_penalty(player: &str) -> Result<String, String> {  
    if player == "Zlatan" {  
        return Ok(String::from("GOAL!"));  
    }  
    Err(String::from("keeper saved it"))  
}  
  
fn main() {  
    let outcome = take_penalty("Messi");  
  
    // Go's if err != nil pattern  
    match outcome {  
        Ok(score) => println!("{}", score),  
        Err(err) => println!("Penalty missed! {}", err),  
    }  
}
// prints
// Penalty missed! keeper saved it
```
- `Result` is similar to `Option` but instead of holding a `Some` or a `None`, **it holds an `OK` or an `Err`**
- often, `Result` and `Option` are used together. Let's imagine you are a football scout, and you've heard of a new talent, Lamine Yamal:
	- `Result` you have to travel to the stadium. If your car breaks down, that is a `Result::Err`. Your mission failed before it even started
	- `Option` is when you arrive at the stadium (`Result::Ok`) but Yamal doesn't score. This is the `Option::None`
```rust
fn scout_yamal(at_stadium: bool) -> Result<Option<String>, String> {  
    if !at_stadium {  
        return Err(String::from("I didn't arrive at the stadium on time"));  
    }  
  
    let goals = 1;  
  
    if goals > 0 {  
        // success -> Yamal scored  
        Ok(Some(String::from("Yamal scored!")))  
    } else {  
        // success -> Yamal didn't score, but at least we arrived at the stadium  
        Ok(None)  
    }  
}  
  
fn main() {  
    let mission_result = scout_yamal(true);  
  
    match mission_result {  
        // Ok -> we arrived at the stadium  
        Ok(maybe_goal) => {  
            match maybe_goal {  
                // Some -> Did Yamal scored?  
                Some(goal) => println!("{}", goal),  
                None => println!("Yamal didn't score"),  
            }  
        }  
        // Err -> car broke and I didn't arrive at the stadium  
        Err(err) => println!("Mission failed: {}", err),  
    }  
}
// prints
// Yamal scored!
```
- just to compare the two, here are their signatures
```rust
enum Option<T> {
    None,
    Some(T),
}
 
enum Result<T, E> {
    Ok(T),
    Err(E),
}
```
- for `Result` both arms have values inside. That is because `Ok` holds a generic type `T` and errors are supposed to have values too. So `Err` holds the generic `E` type. This types can be the same or different 
- `Result<T, E>` means that we need to return something for `Ok` and as well for `Err`
- to prove that we can return **anything** we can even return ()
```rust
fn check_error() -> Result<(), ()> {  
    Ok(())  
}  
  
fn main() {  
    check_error();  
}
```
- the code compiles and the compiler complains
```bash
cargo run
   Compiling tmp v0.1.0 (/home/alex/github.com/tmp_stuff/rust/tmp)
warning: unused `Result` that must be used
 --> src/main.rs:6:5
  |
6 |     check_error();
  |     ^^^^^^^^^^^^^
  |
  = note: this `Result` may be an `Err` variant, which should be handled
  = note: `#[warn(unused_must_use)]` (part of `#[warn(unused)]`) on by default
help: use `let _ = ...` to ignore the resulting value
  |
6 |     let _ = check_error();
  |     +++++++

warning: `tmp` (bin "tmp") generated 1 warning
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.09s
     Running `target/debug/tmp`
```
- the important message from here is `= note: this `Result` may be an `Err` variant, which should be handled`
- this is a good message from the compiler. In Go, we can call a function that returns an error. If we don't assign the error to a variable, the Go compiler stays silent. In Rust, the compiler is like VAR in football. If you, the referee didn't see something, the compiler is calling you to the VAR station to see what you have missed
```rust
fn check_if_goal(ball_crossed_line: bool) -> Result<(), ()> {  
    if ball_crossed_line { Ok(()) } else { Err(()) }  
}  
  
fn main() {  
    let var_review = check_if_goal(false);  
  
    // .is_ok is a quick way to check the happy path  
    if var_review.is_ok() {  
        println!("Goal!");  
    } else {  
        println!("No goal!");  
    }  
}
// prints
// No goal!
```
- **the 4 methods to check the state of `Option` and `Result` are:**
	- `Option` - `.is_some()`, `.is_none()`
	- `Result` - `.is_ok()`, `.is_err()`
- the Go equivalent to errors.New("some message") is using a `String` as the `Err`
- for people not familiar to Go, this is like the referee explaining a decision instead of just blowing the whistle
- let's imagine that in our team, only the number 10 is taking free kicks. If any other player tries to step up, the coach needs to scold the non-assigned player
```rust
fn is_number_ten(jersey_number: u8) -> Result<u8, String> {  
    match jersey_number {  
        10 => Ok(jersey_number),  
        // format!() creates a String, just like fmt.Sprintf in Go  
        _ => Err(format!(  
            "Only number 10 is allowed to take free kicks! {} step down",  
            jersey_number  
        )),  
    }  
}  
  
fn main() {  
    for player_number in 1..=99 {  
        let attempt = is_number_ten(player_number);  
        match attempt {  
            Ok(_) => println!("Player {} is allowed to take free kicks!", player_number),  
            Err(msg) => println!(  
                "Player {} is not allowed to take free kicks! {}",  
                player_number, msg  
            ),  
        }  
    }  
}
// prints
// ...
// Player 8 is not allowed to take free kicks! Only number 10 is allowed to take free kicks! 8 step down
// Player 9 is not allowed to take free kicks! Only number 10 is allowed to take free kicks! 9 step down
// Player 10 is allowed to take free kicks!
// Player 11 is not allowed to take free kicks! Only number 10 is allowed to take free kicks! 11 step down
// Player 12 is not allowed to take free kicks! Only number 10 is allowed to take free kicks! 12 step down
// ...
```
- same as `None` for `Option`, using `.unwrap()` on `Err` panics
```rust
fn main() {  
    let error_value: Result<i32, &str> = Err("There was an error");  
    error_value.unwrap();  
    println!("No goal as error_value.unwrap() panics");  
}
```
- prints:
```bash
cargo run
   Compiling tmp v0.1.0 (/home/alex/github.com/tmp_stuff/rust/tmp)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.08s
     Running `target/debug/tmp`

thread 'main' (174104) panicked at src/main.rs:3:17:
called `Result::unwrap()` on an `Err` value: "There was an error"
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
```
- from the compiler message `thread 'main' (174104) panicked at src/main.rs:3:17:` we can see that in `main.rs` at line 3, column 17 the panic occurs
- we can also create our error types. As examples, Result functions in the standard library usually do this
- the below standard library function is the perfect example
```rust
pub fn from_utf8(vec: Vec<u8>) -> Result<String, FromUtf8Error>
```
- **The Success Case (`Ok`)**: We get a `String`
- **The Error Case (`Err`)**: We get a `FromUtf8Error`
- using our football analogy, to make our own custom struct or enum an "Error", it needs to implement a **Trait** called `Error`
```rust
struct StadiumClosedError; // defining the error

impl std::error::Error for StadiumClosedError {} 
```
- the above is relatively similar to the below, Go code
```go
if err != nil {
    return fmt.Errorf("stadium %s is closed", stadiumName)
}
```

## Other ways to do pattern matching
### if let

- in Go, we often do `val, ok := m["key"]; if ok { ... }`. In Rust, `if let` does both of those lines in one shot. When you only what to take action if the result is `Some` and in the case of `None` do nothing
```rust
fn main() {  
    let striker_shot = Some("Goal by Yamal!");  
    let defender_block: Option<&str> = None;  
  
    // we only care if it's a Goal.  
    // if striker_shot is a Some variant, assign its inner value to 'message'    
    if let Some(message) = striker_shot {  
        println!("The stadium erupts: {}", message);  
    }  
  
    // Since this is None, this block is skipped entirely.  
    // No "else" required, no crash, no noise.    
    if let Some(message) = defender_block {  
        println!("This will never print: {}", message);  
    }  
  
    println!("The game continues...");  
}
// prints
// The stadium erupts: Goal by Yamal!
// The game continues...
```

### let else

```rust
fn main() {  
    let striker_shot = Some("Goal by Yamal!");  
    let defender_block: Option<&str> = None;  
  
    // we only care if it's a Goal.  
    // if striker_shot is a Some variant, assign its inner value to 'message'    
    let Some(message) = striker_shot else {  
        // this runs only if stricker_shot is None  
        return;  
    };  
    println!("The stadium erupts: {}", message);  
  
    // using let else with the blocked shot  
    let Some(new_message) = defender_block else {  
        println!("The defender blocked it! We are exiting main now...");  
        return; // We MUST exit, break, or panic here.  
    };  
  
    println!("This will never print: {}", new_message);  
}
// prints
// The stadium erupts: Goal by Yamal!
// The defender blocked it! We are exiting main now...
```
- the difference between `if let` and `let else` is that in the `if let` example, the code just skipped the block and kept going to "The game continues..". In `let else`, the `else` block **must** divert the flow (usually with `return`). We can print a message and fall through
- notice how `message` is now available in the main scope of the func. We don't have to put the logic inside the curly brackets `{}` anymore

### while let

- `while let` is like a `while` loop for `if let`
```rust
fn main() {  
    let mut game_events = vec![Some("Goal by Yamal!"), Some("Another one by Yamal!"), None];  
    // while we can "pop" a Some event  
    while let Some(Some(event)) = game_events.pop() {  
        println!("The stadium erupts: {}", event);  
    }  
    // the loop stops when it hits the None  
    println!("The defender blocked it! The game continues...");  
}
// prints
// The defender blocked it! The game continues...
```
- but observe what happens when `None` is the first item of the vector
```rust
fn main() {  
    let mut game_events = vec![None, Some("Another one by Yamal!"), Some("Goal by Yamal!")];  
    // while we can "pop" a Some event  
    while let Some(Some(event)) = game_events.pop() {  
        println!("The stadium erupts: {}", event);  
    }  
    // the loop stops when it hits the None  
    println!("The defender blocked it! The game continues...");  
}
// prints
// The stadium erupts: Goal by Yamal!
// The stadium erupts: Another one by Yamal!
// The defender blocked it! The game continues...
```
- because of the `pop()` we are taking the last item until we reach `None` . If the last item is `None` than we follow the `None` flow, ignoring the rest of the `Some` values
- this can be confusing, but think of a deck of cards. In the second example, the `None` card is the first stacked. Then the `Some("Another one by Yamal!")` and then the `Some("Goal by Yamal!")` cards. So when we `pop`, we take the card on top `Some("Goal by Yamal!")` followed by the card in the middle, `Some("Another one by Yamal!")` and then followed by the one at the bottom, `None`

---  
🦀 In the next post, we will explore more complex and interesting collections, the `question mark operator` and when `panic` and `unwrap` are good
