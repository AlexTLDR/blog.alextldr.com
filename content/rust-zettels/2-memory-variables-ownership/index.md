---
title: "How Rust Manages Data: From Variables to Memory Ownership"
date: 2026-02-23
draft: false
description: "Memory management in Rust."
tags:
- rust
- memory
- variables
- ownership
- traits
- copy
- clone
---

# Strings
- there are 2 main types of strings in rust, `String` and `&str`
- strings are UTF-8 encoded
- a `&str` is a simple string, a pointer to the data plus length (Rust knows where it starts and where it ends)
- this is why we need `&` in front of str. This makes a pointer so Rust know what to allocate on the stack
 ```rust
let my_name = "Alex" \\ this is a &str
```

# Pointers
- it is called a reference
- it points to an owned memory location
- pointers in rust are safe by design, as they don't point to random unsafe memory
- tldr you borrow the information
- references in rust are marked with `&`
- you can use this is a freind of a friend for nested references
```rust
let friend = "Alex";
let freind_of_a_friend = &friend;
let friend_of_a-friend_of_a_friend = &friend_of_a_friend
```
- references can go many levels deep but in practice you will not use them so deep

## References
- we can have more references to a value
```rust
fn main() {
    let name = ("Alex");
    let ref_one = &name;
    let ref_two = &name;
    println!("{}", ref_one);
}
// prints Alex
```
- name is a `String` and it owns it's data
- both references are &String and can look into the data
- we can have as many references as we like that only look into the data (not mutable)
```rust
fn return_str() -> &String {
    let name = "Alex";
    let name_ref = &name;
    name_ref
}

fn main() {
    let name = return_str();
}
// errors out
```
- `return_str` creates a `String`, then a reference to that `String` and then it tries to return the reference. But the initial string, `name` only lives in the `return_str` code block. So after the return, the reference is pointing to an already "cleaned" memory
- this is name *owning* "Alex" and *name_ref* only referencing "Alex". When the function returns, name dies and name_ref can't reference it anymore

### References: Ownership vs Borrowing
```rust
fn main() {
    let name = String::from("Alex");
    let ref_one = &name;
    let ref_two = &name;
    println!("{}", ref_one);
    println!("{}", ref_two);
}
```
- this prints:
```bash
cargo run
Compiling tmp v0.1.0 (/home/alex/github.com/tmp_stuff/rust/tmp)
Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.44s
Running `target/debug/tmp`
Alex
Alex
```
- the code works because we created one variable, `name`, which is a `String` that owns its data. We then reference with `ref_one` and `ref_two` the `name` variable. We can create as many references as we want, since the references are of type `&String`. These variables only "look" at the data without modifying it.
- the below code is problematic because we try to return a reference from a function
```rust
fn return_int() -> &i32 {
    let number = 99;
    let number_ref = &number;
    number_ref
}

fn main() {
    let number = return_int();
}
```
- compiler is complaining
```bash
cargo run
Compiling tmp v0.1.0 (/home/alex/github.com/tmp_stuff/rust/tmp)
error[E0106]: missing lifetime specifier
--> src/main.rs:1:20
|
1 | fn return_int() -> &i32 {
|                    ^ expected named lifetime parameter
|
= help: this function's return type contains a borrowed value, but there is no value for it to be borrowed from
help: consider using the `'static` lifetime, but this is uncommon unless you're returning a borrowed value from a `const` or a `static`
|
1 | fn return_int() -> &'static i32 {
|                     +++++++
help: instead, you are more likely to want to return an owned value
|
1 - fn return_int() -> &i32 {
1 + fn return_int() -> i32 {
|

For more information about this error, try `rustc --explain E0106`.
error: could not compile `tmp` (bin "tmp") due to 1 previous error
```
- the `return_int` function is creating an i32 variable, `number`. Then `number` is referenced by `number_ref` with a `&number`. Than it returns `number_ref` (please keep in mind that using the `return` keyword ).  This is not possible because `number` lives only inside the `return_int` function. After the function is executed, `number` dies and `number_ref` refers to an already deleted place in memory.

## Mutable references
- in order to change data via references, you can use mutable references
- you can change data through a reference by using `&mut` instead of `&`
- in order to change the value through a reference, you need to *dereference*
```rust
fn main() {
    let mut integer = 1;
    let integer_reference = &mut integer;
    // integer_reference += 10 doesn't work
    *integer_reference += 10; // correctr way to dereference
    println!("{}", integer); // prints 11
}
```

### You can have many immutable references but only **one** mutable reference. You **can't have an immutable and a mutable reference** together
```rust
fn main() {
    let mut integer = 1;
    let integer_reference = &integer;
    let integer_change = &mut integer;
    *integer_change += 10;
    println!("{}", integer_reference);
}
/*
error[E0502]: cannot borrow `integer` as mutable because it is also borrowed as immutable
*/
```
- but if we move the reference after the mutable reference, the code compiles
```rust
fn main() {
    let mut integer = 1;
    let integer_change = &mut integer;
    *integer_change += 10;
    let integer_reference = &integer;
    println!("{}", integer_reference);
}
// prints 11
```
- in this case the mutable reference alters the initial value of `integer` and `integer_reference` "refers" the new value of `integer`

Shadowing
-  shadowing blocks a value
```rust
fn main() {
    let name = ("Alex");
    let name_ref = &name;
    let name = 99;
    println!("{}: {}", name_ref, name);
}
// prints Alex: 99
```
- `name = ("Alex")` is shadowed by `name = 99`

## Examples of making Rust strings
- `String::from("Alex");` -> this is a method for `String` that creates a string from text
- `"Alex".to_string()` -> this is a method for `&str` that transforms it to a `String`
- `format!` macro works the same as `println!` macro but it just creates the text
```rust
let name = "Alex";
let sport = "football";
let fav_team = "Rapid";
let example = format!("My name is {name}, I am a big fan of {sport} and my favorite team is {fav_team}");
```
- using `.into()`:
- this is not straight forward
```rust
let name = "Alex".into() //will not work
let name: String = "Alex".into() //works
```
- Rust needs to know the type of the variable to know into what type to make the variable. For this, **Type Annotation** is required -> `: String`
- this works because of a thing called **blanket trait implementation**

## References in functions
- since values can have only one owner, this means a value once used, it is destroyed
- because of this, the below code won't work
```rust
fn print_name(name: String) {
    println!("{name}");
}

fn main() {
    let name = String::from("Alex");
    print_name(name);
    print_name(name);
}
```
```bash
cargo run
Compiling tmp v0.1.0 (/home/alex/github.com/tmp_stuff/rust/tmp)
error[E0382]: use of moved value: `name`
--> src/main.rs:8:16
|
6 |     let name = String::from("Alex");
|         ---- move occurs because `name` has type `String`, which does not implement the `Copy` trait
7 |     print_name(name);
|                ---- value moved here
8 |     print_name(name);
|                ^^^^ value used here after move
|
note: consider changing this parameter type in function `print_name` to borrow instead if owning the value isn't necessary
--> src/main.rs:1:21
|
1 | fn print_name(name: String) {
|    ----------       ^^^^^^ this parameter takes ownership of the value
|    |
|    in this function
help: consider cloning the value if the performance cost is acceptable
|
7 |     print_name(name.clone());
|                    ++++++++

For more information about this error, try `rustc --explain E0382`.
error: could not compile `tmp` (bin "tmp") due to 1 previous error
```
- as described by the error, this is a move, because the data moves into the function and it dies after the function executes
- the first run of the `print_name` function consumes the data (the function doesn't use `->` to return something) and when we call the function the same time with `name`, `name` is already dead
- because the data "moves" into the function, this is called a **move**
- in order to fix this, just use references
```rust
fn print_name(name: &String) {
    println!("{name}");
}

fn main() {
    let name = String::from("Alex");
    print_name(&name);
    print_name(&name);
}
// this prints
// Alex
// Alex
```
- now `print_name` takes a reference to a `String`, a `&String`. This way, `print_name` only views the data but doesn't "own" it
- the same, we can use a function with a mutable reference
```rust
fn create_nickname(nick: &mut String) {
    nick.push_str("TLDR");
    println!("My nickname is: {nick}");
}

fn main() {
    let mut name = String::from("Alex");
    create_nickname(&mut name);
}
// My nickname is: AlexTLDR
```
- function `create_nickname` "borrows" a `String` and changes it. The variable is only mutated but doesn't die inside the function

# Copy types

- these are the simplest types
- because the compiler always knows their size, they are on the stack
- because of this, the compiler always copies their data when these types are sent to a function. This means that you don't have to worry about ownership
- copy types are the integer types, floating point types, boolean and Characters
- compound types, if they contain only copy types, like [i32; 10] or (i64, bool), etc
- shared reference as well, like `&T` is always a copy type, but a `&mut T` is never a copy type
- in order to check if a type implements the "copy" trait, you can check the documentation of the type
- here is an example for bool -> https://doc.rust-lang.org/std/primitive.bool.html#impl-Copy-for-bool

# Clone

- if a type doesn't implement copy, clone can be used instead
- clone is more expensive to use
- every time `.clone()` is called, the whole content is cloned in memory
- for example with a `String`, that can be a whole book, this will be a costly operation
- a way to fix the example from References in functions, is to use the `.clone()` trait in the 1st function call
```rust
fn print_name(name: String) {
    println!("{name}");
}

fn main() {
    let name = String::from("Alex");
    print_name(name.clone());
    print_name(name);
}
// Alex
// Alex
```

### TLDR, the rule of thumb is: **Default to immutable references (`&T`) whenever possible.**
# const and static
- `const` is created at compile time and it never changes
- `static` is similar to `const` but in a fixed memory location
- they don't use `let` to declare them
- they are global variables written with CAPITAL LETTERS and usually outside of main so they can live for the whole execution of the program
- being global they are accessible from everywhere and they aren't dropped
```rust
const NUMBER_OF_WEEKDAYS = 5;
const NUMBER_OF_WEEKEND_DAYS = 2;
static WORK_DAYS: [&str; 5] = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday"]
static WEEKEND_DAYS: [&str; 2] = ["Saturday", "Sunday"]
```
- `const` and `static` are made at compile time, so the compiler knows exactly the values
- because of this, we don't need to worry about ownership

# Uninitialized variables
- they are variables without a value
- you only write `let` and the name of the variable
```rust
let name: String;
```
- they are useful for:
    - **Scoped Logic:** The variable’s value is generated inside a block
    - **Extended Lifetime:** The variable must persist after the block ends
    - **Names First:** The variable name is highlighted before its definition for better readability

```rust
fn main() {
    let nickname;
    {
        let mut name = String::from("Alex");
        name.push_str("TLDR");
        nickname = name;
        println!("{nickname}");
    }
}
// AlexTLDR
```
---
🦀 *Since I didn't keep my promise last week, of posting at least once per week, my next post will be this week. It will be focused on printing and formating output in Rust.*
