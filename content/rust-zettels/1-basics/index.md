---
title: "Basics of Rust"
date: 2026-02-10
draft: false
description: "Introduction to Rust."
tags:
  - rust
---

## Is Rust a good first language?

> Below is what copilot from my IDE suggested
>> No. Rust is not a good first language. It is a complex language with a steep learning curve. It has a lot of
features that are not necessary for beginners, and it has a lot of rules that are not intuitive. It is a great
language for systems programming, but it is not a great language for learning programming.

I think a lot of people don't need copilot to tell them that. This is the majority opinion in the programming comunities.
Most of the people consider Rust as a second or third language to learn. I would say that my 1st language is Go, but in
my learning journey I touched Python as well, even used it in my DevOps roles. Besides Python, I have touched a little C and 
JavaScript. I have used C in learning projects, to better understand memory management and JS mostly to help with the frontend
part of my projects.

From the languages mentioned above, I can say that I formed an opinion regarding type safety and this was the main reason
I chose Go as my primary language. I simply didn't start with programming like a lot of people do, by learning Python
for it's English like syntax because I missed the type safety. Go was the best choice for me at the time.

Now starting to learn Rust, being approx 3-4 months in the process, I would disagree with everybody that thinks that Rust
is not a great 1st language. I believe it has all the ingredients to teach a new programmer about a lot of CS aspects.
For example it has the classic primitives like i8, i16, i32, i64, u8, u16, u32, u64, f32, f64, char, bool, and also 
strings. Besides the classic primitives it also has more "weird" types like i128 or u128, which not all the languages have.

Because Rust is focused on speed, it teaches you how to use types efficiently. For example -13 in i8 is stored as 11110101,
while in i16 it is stored as 1111111111110101, in i32 it is stored as 11111111111111111111111111110101, and in i64 it is 
stored as 111111111111111111111111111111111111111111111111111111111110101. This teaches you about memory efficiency.

Because of ownership, the programmer learns about memory management. If Go is garbage collected, and the GC is handling
most of the memory management, Rust is using lifetimes. After a variable is out of scope, it is dropped and it no longer
exists. 

With imutable variables by default, the programmer is forced to think about the data and how it is used. If a variable
should be changed, it needs to be explicitly marked as mutable.

Type strictness teaches the programmer about types and how to use them efficiently. The compiler is most of the time smart
enough to infer (guess) the type of a variable, but the programmer has the freedom to be explicit about what types they want to use.

In the below example, the compiler will infer that x and y are f64, and z will also be f64.
```
fn main() {
    let x = 1.0;
    let y = 3.14;
 
    let z = x + y;
}
```

In the below example, because x is f32, the compiler will infer that y is also f32, and z will be f32 as well.

```
fn main() {
    let x: f32 = 1.0;
    let y = 3.14;
 
    let z = x + y;
}
```
Another strong argument is the compiler paired with [Clippy](https://doc.rust-lang.org/stable/clippy/index.html). The 
compiler "complains" everytime something is not right, and Clippy "complains" everytime something is not idiomatic. 
This teaches the beginner to write clean code from the start. Reading the below code and the compiler output, it is easy
to understand what is wrong and how to fix it.

```
fn main() {
    let x: f32 = 1.0;
    let y: f64 = 3.14;
 
    let z = x + y;
}
```
The code will return the following error:
```
cargo run
   Compiling ignore v0.1.0 (/home/alex/github.com/AlexTLDR/rust-sandbox/ignore/ignore)
error[E0308]: mismatched types
 --> src/main.rs:5:17
  |
5 |     let z = x + y;
  |                 ^ expected `f32`, found `f64`

error[E0277]: cannot add `f64` to `f32`
 --> src/main.rs:5:15
  |
5 |     let z = x + y;
  |               ^ no implementation for `f32 + f64`
  |
  = help: the trait `Add<f64>` is not implemented for `f32`
  = help: the following other types implement trait `Add<Rhs>`:
            `&f32` implements `Add<f32>`
            `&f32` implements `Add`
            `f32` implements `Add<&f32>`
            `f32` implements `Add`

Some errors have detailed explanations: E0277, E0308.
For more information about an error, try `rustc --explain E0277`.
error: could not compile `ignore` (bin "ignore") due to 2 previous errors
```
It is clear that the compiler is telling us that we are trying to add two different types, and it also gives us a hint
on how to fix it.

**These are just some reasons that I believe Rust is a great language for a beginner to learn. I would say that programming
in general is hard to learn and that you need to put in the time, but Rust gives you a structure that helps you to write
good code from the start.**

# Now let's do some Rust basics

