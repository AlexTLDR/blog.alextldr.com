---
title: "Arrays, Vectors and Tuples"
date: 2026-03-02
draft: false
description: "Arrays, Vectors and Tuples in Rust."
tags:
- rust
- arrays
- vectors
- tuples
- complex types
---

# Arrays, Vectors and Tuples

- Arrays are simple, fast, immutable collections of the same type
- Vectors are similar to arrays but growable. Similar to slices in Go
- Tuples are a grouping of various types

## Arrays
- create an array by putting data inside square brackets
- arrays must only contain the same type
- arrays are of fixed size
- the type of the array is declared as `[type; number]` type being the type of the values it holds and number being the length of the array
```rust
fn main() {
    let array1 = [1, 2, 3]; // [i32; 3]
    let array2 = [1, 2, 3, 4]; // [i32; 4]
}
```
- declaring an array with the same value repeating, in the square brackets, you can declare it by entering the value, then a semicolon and then the number of times you want to repeat
```rust
fn main() {
    let array = [1; 5];
    let hello_array = ["hello"; 5];
    println!("{:?} {:?}", array, hello_array);
}
/// [1, 1, 1, 1, 1] ["hello", "hello", "hello", "hello", "hello"]
```
- the above method of writing arrays is used primarily for creating buffers
- if the array is declared with `mut` you can change the data inside. You just can't add/remove (change the array's length) or change the item type of the values inside the array
- you can use indexes to access array elements. As in most programming languages, the index starts from 0. So the 1st element is [0], second [1] and so on```
```rust
fn main() {
    let my_name = ['A', 'l', 'e', 'x'];
    println!("The first letter of my name is {}", my_name[0]);
}
// The first letter of my name is A
```
- as in Go, you can slice an array. The difference is that Go uses the colon `myArray[x:y]` and Rust uses the Range Operator `..` , `&my_array[x..y]` . But both have a *start* and an *end*
- in Rust, you need the `&` when slicing an array because the compiler doesn't know the size. When you write `let slice = &my_array[2..5]`, you are creating a **Fat Pointer**. This pointer contains the memory address of index 2 and the length of the slice (which is 3 in this case)
- just like Go, if you try to slice an array at an index that doesn't exist (e.g. &my_array[10..20] on a 5 element array), Rust will panic at runtime to prevent you from reading *garbage* memory
```rust
fn main() {
    let my_name = ['A', 'l', 'e', 'x'];
    let sliced = &my_name[1..3];
    println!("The middle letters from my name are {:?}", sliced);
}
// The middle letters from my name are ['l', 'e']
```

## Vectors
- the main difference between arrays and vectors is that vectors are dynamically sized (as mentioned in the beginning, similar to Go slices)
- as slices, vectors work with only one type for their items
- like slices, the type of the items can't be changed
- because of this flexibility, vectors are stored on the heap, making them slower than arrays, which are stored on the stack
- the vector type is written with the keyword `Vec`
```rust
fn main() {
    let first_name = String::from("John");
    let second_name = String::from("Doe");
    let mut full_name_vec = Vec::new(); // without at least one push from below
    // the compiler won't know the type of the Vec
    full_name_vec.push(first_name);
    full_name_vec.push(second_name);
    println!("Full name: {:?}", full_name_vec);
}
// Full name: ["John", "Doe"]
```
- instead of letting Rust through type inference decide the type, like above, you can declare the type, by using *angle brackets* `<>` , and annotating the type between the brackets
```rust
fn main() {
let mut my_vec: Vec<i32> = Vec::new();
    my_vec.push(1);
    my_vec.push(2);
    my_vec.push(3);
    println!("My vector: {:?}", my_vec);
}
// My vector: [1, 2, 3]
```
- easier to declare vectors, is the use of the `vec!` macro
```rust
fn main() {  
    let mut my_vec = vec![1, 2, 3];  
}
```
- you can slice a vector the same as you would slice an array
```rust
fn main() {  
    let my_name = vec!['A', 'l', 'e', 'x'];  
    let sliced = &my_name[1..3];  
    println!("The middle letters from my name are {:?}", sliced);  
}  
// The middle letters from my name are ['l', 'e']
```
- as slices in Go, vectors have a capacity. If you go over the capacity, the vector will double its capacity. So a vector with a capacity of 3, will double to a capacity of 6 if you want to push to it the 4th element
- when a vector doubles its capacity, it will allocate the memory for the new capacity and copy the old vector plus the new item pushed on to the new memory location. This is called reallocation. Again, this is a similar mechanism to Go slices
- if you push to a vector with 0 elements, the new capacity will always be 4 (and after the doubling rule starts)
```rust
fn main() {  
    let mut num_vec = Vec::new();  
    println!("{}", num_vec.capacity()); // 0  
    num_vec.push('A');  
    println!("{}", num_vec.capacity()); // 4  
    num_vec.push('l');  
    num_vec.push('e');  
    num_vec.push('x');  
    num_vec.push('T');  
    println!("{}", num_vec.capacity()); // 8  
    num_vec.push('L');  
    num_vec.push('D');
    num_vec.push('R');  
    println!("{}", num_vec.capacity()); // still 8 since we didn't 
    // overflow the len of the vector  
}
// 0
// 4
// 8
// 8
```
- we can be more efficient by declaring the new vector with a length by using `Vec::with_capacity(16)` 
```rust
fn main() {  
    let mut num_vec = Vec::with_capacity(16);  
    println!("{}", num_vec.capacity()); // 16  
    num_vec.push('A');  
    println!("{}", num_vec.capacity()); // no need to reallocate4  
    num_vec.push('l');  
    num_vec.push('e');  
    num_vec.push('x');  
    num_vec.push('T');  
    println!("{}", num_vec.capacity()); // no need to reallocate  
    num_vec.push('L');  
    num_vec.push('D');  
    num_vec.push('R');  
    num_vec.push('!');  
    println!("{}", num_vec.capacity()); // no need to reallocate 
    // as final len is 9  
}
```
- we can use the `.into()` method to make an array into a `Vec`. Because of type inference, you don't need to specify the type of the vector, just declare the vector as `Vec<_>` as Rust will infer the type from the array

## Tuples

- since tuples in Rust are written between brackets `()` we have already seen them in action. `fn my_func() {}` already contains a nothing tuple in the signature
- the `fn my_func() {}` gets nothing, an empty tuple, and returns nothing
- when nothing is returned by a function, it is returned an empty tuple
- this empty tuple is called an unit type
- items inside tuples are accessed via index base, but a dot `.` is used to access them
```rust
fn main() {  
   let my_tuple = ("AlexTLDR", 86, 'A',true);  
   println!("The first element is {}, second {}, third {}, fourth {}", my_tuple.0, my_tuple.1, my_tuple.2, my_tuple.3);  
}
// The first element is AlexTLDR, second 86, third A, fourth true
```
- the type of the tuple is the type of the items inside the tuple
- the above tuple is of type `(&str, {integer}, char, bool)`
- tuples can be used for multiple variables declarations
```rust
fn main() {  
   let chars = ('A', 'l', 'e', 'x');  
   let (a,l,e,x) = chars;  
   println!("The first letter of my name is {}, second {}, third {}, fourth {}", a, l, e, x);  
}
// The first letter of my name is A, second l, third e, fourth x
```
- the above is called destructuring
- destructuring only works if the patern matches
```rust
fn main() {  
   let chars = ('A', 'l', 'e', 'x');  
   let (a,l,e,x,T) = chars;  
   println!("The first letter of my name is {}, second {}, third {}, fourth {}", a, l, e, x);  
}
```

```bash
cargo run
   Compiling tmp v0.1.0 (/home/alex/github.com/tmp_stuff/rust/tmp)
error[E0308]: mismatched types
 --> src/main.rs:3:8
  |
3 |    let (a,l,e,x,T) = chars;
  |        ^^^^^^^^^^^   ----- this expression has type `(char, char, char, char)`
  |        |
  |        expected a tuple with 4 elements, found one with 5 elements
  |
  = note: expected tuple `(char, char, char, char)`
             found tuple `(_, _, _, _, _)`

For more information about this error, try `rustc --explain E0308`.
error: could not compile `tmp` (bin "tmp") due to 1 previous error
```
- you can use the underscore `_` for pattern matching
```rust
fn main() {  
   let chars = ('A', 'l', 'e', 'x');  
   let (a,_,_,_) = chars;  
   println!("The first letter of my name is {}", a);  
}
// The first letter of my name is A
```
---
🦀 In the next post, we will cover control flow
