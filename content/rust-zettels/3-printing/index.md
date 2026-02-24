---
title: "Printing and formating output in Rust"
date: 2026-02-24
draft: false
description: "Printing and formating output in Rust."
tags:
- rust
- printing
- formating
- output
- println
- format
- print
- debug
- display
---

# Printing
- `println!` can print with `{}` for `Display`
- `println!` can print with `{:?}` for `Debug`
- `println!` can print with `{:#?}` for `pretty printing`
- `println!` can print with `{:p}` for printing the pointer address
```rust
fn main() {
    let name = "Alex";
    let name_ref = &name;
    println!("{:p}", name_ref);
}
// 0x7ffeb0d200e8
```
- `println!` can print binary, hexadecimal and octal
```rust
fn main() {
    let foo = 26;
    println!("Binary: {:b}, hexadecimal: {:x}, octal: {:o}", foo, foo, foo);
}
// Binary: 11010, hexadecimal: 1a, octal: 32
```
- adding `\n` will make a new line and adding `\t` will make a tab
```rust
fn main() {
    print!("\tStart with a tab\nand continue with a new line");
}
```
- and it prints
```bash
cargo run
Compiling tmp v0.1.0 (/home/alex/github.com/tmp_stuff/rust/tmp)
Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.09s
Running `target/debug/tmp`
    Start with a tab
and continue with a new line%
```
- between quotes, `""` you can write over multiple lines
- escape characters `\` are using for escaping special characters like `\n`
```rust
fn main() {
    println!("this is how to escape characters: \\n and \\t");
}
// this is how to escape characters: \n and \t
```
- raw strings are between `r#` and an ending `#`
```rust
fn main() {
    println!(r#"this is a raw string: \n and \t. Because it is a raw string, \n and \t don't need to be escaped."#);
}
// this is a raw string: \n and \t. Because it is a raw string, \n and \t don't need to be escaped.
```
- for printing the bytes of a `&str` or `char`, write b in front of the string. This is compatible with all the ASCII characters
```rust
fn main() {
    println!("{:?}", b"AlexTLDR");
}
// [65, 108, 101, 120, 84, 76, 68, 82]
```
- `b` can be combined with the `r#` syntax, to print the bytes of the raw string
- using the Unicode escape, you can print any Unicode character inside a string, `\u{}`. A hexadecimal number, which represents the character's number, goes inside the `{}`
```rust
fn main() {
    let crab = '🦀';
    let alpha = 'α';
    let infinity = '∞';

    println!("Hex codes: {:X}, {:X}, {:X}", crab as u32, alpha as u32, infinity as u32);
    println!("Literal output: \u{1F980}, \u{3B1}, \u{221E}");
}
// Hex codes: 1F980, 3B1, 221E
// Literal output: 🦀, α, ∞
```
- adding numbers inside of `{}` will change the printing order
```rust
fn main() {
    let one = "foo";
    let two = "bar";
    let three = "buz";
    println!("reversed printed {2} -> {1} -> {0}", one, two, three)
}
// reversed printed buz -> bar -> foo
```
- names instead of index values can be used between `{}`
```rust
    fn main() {
    let one = "foo";
    let two = "bar";
    let three = "buz";
    println!("printed using the names {one} -> {two} -> {three}")
}
// printed using the names foo -> bar -> buz
```
### Complex printing
- the formula for complex printing is
```rust
{variable:padding alignment minimum.maximum}
```
- in the below example, **`✨`** is a fill character, `^` is the alignment and `10` is the width
```rust
fn main() {
    let name = "Alex";

    // We want a total width of 10 characters.
    // '^' means center alignment.    // '✨' is our fill character.
    println!("{:✨^10}", name);
}
// ✨✨✨Alex✨✨✨
```
- **Fill Character (`✨`):** Any single character used to fill empty space
- **Alignment (`^`, `<`, `>`):** Center, Left, or Right
- **Width (`10`):** The total minimum number of characters in the output
- **Precision (`.2`):** (For floating point or limiting string length)
---
🦀 In the next post, we will cover arrays, vectors, and tuples