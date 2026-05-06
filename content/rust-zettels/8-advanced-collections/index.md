---
title: "Advanced collections"
date: 2026-05-06
draft: false
description: "Data collections or containers"
tags:
- rust
- HashMap
- BTreeMap
- .entry() method
- HashSet
- BTreeSet
- BinaryHeap
- VecDeque
- Data collections
---

Go prides on simplicity. For almost every data problem, the answer is mostly the two reliable tools, the `Slice` and the `Map`. This Swiss Army knife style makes Go code easy to read, but it sometimes forces developers to build custom logic when they need ordered maps or double-ended queues.

Rust follows a different philosophy. Rust is more like a **specialized toolbox**. While most of the time we use `Vec` (slices) and `HashMap` (maps), Rust offers some **precision tools** for specific performance or sorting needs.

- need your keys always sorted? **BTreeMap**
- need to add/remove items from both ends of a list? **VecDequeue**
- need a map with a unique set of items? **HashSet**

Before jumping into each other, I want to mention that all of these collections are in the same spot, at `std::collections` and to use them, we need to bring them into scope with the `use` statement (something that we already did in previous posts). The standard library has a dedicated [page](https://doc.rust-lang.org/std/collections/index.html#when-should-you-use-which-collection) regarding when we should use which collection.

## HashMap and BTreeMap

- similar to Go's map type, a `HashMap` is a collection of *keys* and *values*. We use the key to look up the value that matches that key
- like in Go, the keys in a `HashMap` **must** be unique
- if we insert a key that already exists, Rust will overwrite the old value with the new one (again, like Go)
- since in the last post I used football references for my examples, I will try to use cars in this one. An example of a key - value pair is `ABC-1234` and `Silver Miata`, where `ABC-1234` is the key (the license plate) and `Silver Miata` is the value
```rust
use std::collections::HashMap;  
  
fn main() {  
    // creating the garage map  
    let mut garage = HashMap::new();  
    // inserting the cars using the license plate  
    garage.insert("ABC-1234", "Silver Miata");  
    garage.insert("DEF-5678", "White Hyundai");  
  
    let plate = "ABC-1234";  
  
    // .get() returns an Option<&V>  
    match garage.get(plate) {  
        Some(car) => println!("{} is in the garage.", car),  
        None => println!("{} is not in the garage.", plate),  
    }  
}
// prints
// Silver Miata is in the garage.
```
- the keys of a `HashMap` are not ordered (again, like in Go)
```rust
use std::collections::HashMap;  
  
fn main() {  
  
    let mut garage = HashMap::new();  
  
    garage.insert("ABC-1234", "Silver Miata");  
    garage.insert("DEF-5678", "White Hyundai");  
    garage.insert("ZYX-9999", "Red Ferrari");  
    garage.insert("MNO-5555", "Blue Truck");  
    garage.insert("DEF-6789", "Black SUV");  
  
    println!("--- Iterating through the HashMap ---");  
  
    for (plate, car) in garage {  
        println!("License Plate: {}, Car: {}", plate, car);  
    }  
}
```
- below two results on two different `cargo run` commands
```bash
cargo run
   Compiling tmp v0.1.0 (/home/alex/github.com/tmp_stuff/rust/tmp)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.11s
     Running `target/debug/tmp`
--- Iterating through the HashMap ---
License Plate: DEF-5678, Car: White Hyundai
License Plate: ABC-1234, Car: Silver Miata
License Plate: MNO-5555, Car: Blue Truck
License Plate: DEF-6789, Car: Black SUV
License Plate: ZYX-9999, Car: Red Ferrari
 alex@lunar-arch  ~/github.com/tmp_stuff/rust/tmp   main  cargo run
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.00s
     Running `target/debug/tmp`
--- Iterating through the HashMap ---
License Plate: DEF-5678, Car: White Hyundai
License Plate: DEF-6789, Car: Black SUV
License Plate: ABC-1234, Car: Silver Miata
License Plate: ZYX-9999, Car: Red Ferrari
License Plate: MNO-5555, Car: Blue Truck
```
- if you want a `HashMap` that orders the keys, use `BTreeMap`
```rust
use std::collections::BTreeMap;  
  
fn main() {  
  
    let mut garage = BTreeMap::new();  
  
    garage.insert("ABC-1234", "Silver Miata");  
    garage.insert("DEF-5678", "White Hyundai");  
    garage.insert("ZYX-9999", "Red Ferrari");  
    garage.insert("MNO-5555", "Blue Truck");  
    garage.insert("DEF-6789", "Black SUV");  
  
    println!("--- Iterating through the HashMap ---");  
  
    for (plate, car) in garage {  
        println!("License Plate: {}, Car: {}", plate, car);  
    }  
}
```
- using the same example, but replacing the `use` statement with `std::collections::BTreeMap` and declaring the `garage` variable as `BTreeMap::new()` we get the same output but ordered by key name
- below is the output of the command ran multiple times
```bash
 alex@lunar-arch  ~/github.com/tmp_stuff/rust/tmp   main  cargo run
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.00s
     Running `target/debug/tmp`
--- Iterating through the HashMap ---
License Plate: ABC-1234, Car: Silver Miata
License Plate: DEF-5678, Car: White Hyundai
License Plate: DEF-6789, Car: Black SUV
License Plate: MNO-5555, Car: Blue Truck
License Plate: ZYX-9999, Car: Red Ferrari
 alex@lunar-arch  ~/github.com/tmp_stuff/rust/tmp   main  cargo run
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.00s
     Running `target/debug/tmp`
--- Iterating through the HashMap ---
License Plate: ABC-1234, Car: Silver Miata
License Plate: DEF-5678, Car: White Hyundai
License Plate: DEF-6789, Car: Black SUV
License Plate: MNO-5555, Car: Blue Truck
License Plate: ZYX-9999, Car: Red Ferrari
```
- besides the key order, `HashMaps` and `BTreeMaps` are similar and the below applies to both
- the simplest way to get the value is by putting the key in square brackets `[]`, similar to how we index access values in a `Vec`
```rust
use std::collections::BTreeMap;  
  
fn main() {  
  
    let mut garage = BTreeMap::new();  
  
    garage.insert("ABC-1234", "Silver Miata");  
    garage.insert("DEF-5678", "White Hyundai");  
    garage.insert("ZYX-9999", "Red Ferrari");  
    garage.insert("MNO-5555", "Blue Truck");  
    garage.insert("DEF-6789", "Black SUV");  
    // accessing a value by key  
    let my_car = garage["ABC-1234"];  
    println!("My car is: {}", my_car);  
}
// prints
// My car is: Silver Miata
```
- easy right? but what happens if I `let my_car = garage["doesn't exist"]` ?
```rust
use std::collections::BTreeMap;  
  
fn main() {  
  
    let mut garage = BTreeMap::new();  
  
    garage.insert("ABC-1234", "Silver Miata");  
    // trying to access a non-existing value  
    let my_car = garage["doesn't exist"];  
    println!("My car is: {}", my_car);  
}
```
- unlike Go, which returns the zero value of the type, Rust panics with the below message
```rust
cargo run
   Compiling tmp v0.1.0 (/home/alex/github.com/tmp_stuff/rust/tmp)
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.12s
     Running `target/debug/tmp`

thread 'main' (54337) panicked at src/main.rs:9:24:
no entry found for key
note: run with `RUST_BACKTRACE=1` environment variable to display a backtrace
```
- in my first example of this post, I have used the `.get()` method, which returns an `Option`. This way we guard ourselves against panics
```rust
use std::collections::HashMap;  
  
fn main() {  
    // creating the garage map  
    let mut garage = HashMap::new();  
    // inserting the cars using the license plate  
    garage.insert("ABC-1234", "Silver Miata");  
    garage.insert("DEF-5678", "White Hyundai");  
  
    let plate = "ABC-1234";  
  
    // .get() returns an Option<&V>  
    match garage.get(plate) {  
        Some(car) => println!("{} is in the garage.", car),  
        None => println!("{} is not in the garage.", plate),  
    }  
}
// prints
// Silver Miata is in the garage.
```
- or when the value doesn't exist
```rust
use std::collections::HashMap;

fn main() {
    // creating the garage map  
    let mut garage = HashMap::new();
    // inserting the cars using the license plate  
    garage.insert("ABC-1234", "Silver Miata");
    garage.insert("DEF-5678", "White Hyundai");

    let plate = "doesn't exist";

    // .get() returns an Option<&V>  
    match garage.get(plate) {
        Some(car) => println!("{} is in the garage.", car),
        None => println!("{} is not in the garage.", plate),
    }
}
// prints
// doesn't exist is not in the garage.
```
- it is self-explanatory why `.get()` is the better approach
- we already learned that inserting (`.insert()`) into a key that already exists, it will overwrite the value of that key. But how do we guard ourselves against it?
```rust
use std::collections::HashMap;  
  
fn main() {  
    let mut garage = HashMap::new();  
    let plate = "ABC-1234";  
    let car = "Silver Miata";  
  
    if garage.get(plate).is_none() {  
        garage.insert(plate, car);  
        println!("Parking the car in the garage: {}", car);  
    } else {  
        println!("Car already parked in the garage: {}", car);  
    }  
}
// prints
// Parking the car in the garage: Silver Miata
```
- there are more ways to do the same check. The above is the boolean way, by using `is_none`
- we can also do the pattern way, with `if let`
```rust
if let Some(existing_car) = garage.get(plate) {
    println!("Cannot insert. Spot is held by a {}", existing_car);
} else {
    garage.insert(plate, car);
}
```

### The .entry() method

- or in a more efficient way, by using `.entry`. This method is designed specifically for this check and insert logic. It is more efficient because it only searches the map once
```rust
use std::collections::HashMap;

fn main() {
    let mut garage = HashMap::new();
    let plate = "ABC-1234";
    let car = "Silver Miata";
    let second_car = "White Hyundai";

    let occupant = garage.entry(plate).or_insert(car);
    println!("The parked car is {} {}", plate, occupant);

    // 2. Second car tries to push into the SAME occupied spot
    // .or_insert() checks the spot: "Is it empty?"
    // Since it's NOT empty, the "White Hyundai" is ignored.
    garage.entry(plate).or_insert(second_car);
    println!("After the second attempt, \
    in the parking spot the car is {} with a plate of {}", garage[plate], plate);
}
// prints
// The parked car is ABC-1234 Silver Miata
// After the second attempt, in the parking spot the car is Silver Miata with a // plate of ABC-1234
```
- let's look at how `.entry()` and `.or_insert` work
- `pub fn entry(&mut self, key: K) -> Entry<K, V>` . Official page for [Entry](https://doc.rust-lang.org/std/collections/hash_map/enum.Entry.html)or a simplified enum version:
```rust
enum Entry<K, V> {
    Occupied(OccupiedEntry<K, V>), // "Someone is already parked here"
    Vacant(VacantEntry<K, V>),     // "The parking spot is free"
}
```
- this means that the `HashMap` will check what key it got and it will return an `Entry` that matches if there is a value or not
- `.or_insert()` is a method on the `Entry` enum
```rust
fn or_insert(self, default: V) -> &mut V {
    match self {
        Occupied(entry) => entry.into_mut(),
        Vacant(entry) => entry.insert(default),
    }
}
```
- the most important part is that it always returns a mutable reference, `&mut V`. The match arm either returns a mutable reference to the existing value or it inserts the default value and returns a mutable reference to it
- because `.or_insert()` always returns a **mutable reference (`&mut V`)**, it acts like a direct "remote control" to the value inside the `HashMap`
- whether the parking spot was already recorded or the `HashMap` just created a new entry for you, you end up with a variable that points exactly to the memory where that data lives. This allows you to update the value in-place without searching the map a second time
- let’s build a **Visit Counter**. We want to track how many times a car with a specific plate enters our garage.
```rust
use std::collections::HashMap;

fn main() {
    let mut visit_log = HashMap::new();
    let plate = "ABC-123";

    for _ in 0..3{
        // .or_insert(0) returns a &mut i32 (a pointer to the counter)
        let visit_count = visit_log.entry(plate).or_insert(0);
        // dereferencing with the *
        *visit_count += 1;
    }
    println!("Plate {} has visited {} times", plate, visit_log[plate]);
}
// prints
// Plate ABC-123 has visited 3 times
```
- we can use `.or_insert()` to insert a `Vec` and to push values on it. Let's track **fueling costs** for cars. Each time a car visits our garage, we track the costs
```rust
use std::collections::HashMap;

fn main() {
    let mut gas_logs = HashMap::new();
    let plate = "ABC-123";

    let new_invoices = vec![45, 30, 55];

    for i in new_invoices {
        let entry = gas_logs.entry(plate).or_insert(vec![]);

        entry.push(i);
        println!("Entry number {} is {}",  entry.len(), i);
    }
    println!("Full log is {:?}", gas_logs);
}
// prints
// Entry number 1 is 45
// Entry number 2 is 30
// Entry number 3 is 55
// Full log is {"ABC-123": [45, 30, 55]}
```
- in the first iteration, the `HashMap` sees the key `ABC-123`. It checks to see if the key is already in the `HashMap`. Since it is not, it will insert a `Vec::new()` and return the mutable reference to it. After the `Vec` is created, it uses `.push()` to push the 1st number.
- in the rest of the iterations, it sees `ABC-123` already in the `HashMap`. In this case, it will not insert a new `Vec`, but will return the mutable reference to the `Vec` and pushes a new invoice 

## HashSet and BTreeSet

- from the [Rust Docs](https://doc.rust-lang.org/std/collections/struct.HashSet.html) ,a [hash set](https://doc.rust-lang.org/std/collections/index.html#use-the-set-variant-of-any-of-these-maps-when "mod std::collections") is implemented as a `HashMap` where the value is the **unit type** `()`
```rust
use std::collections::HashSet;

fn main() {
    let mut visited_today = HashSet::new();

    visited_today.insert("ABC-123");
    visited_today.insert("DE-2021");
    visited_today.insert("GD-1923");
    // If we add the same plate again, it just stays as one entry (unique)
    visited_today.insert("ABC-123");
    
    // Checking for a car is fast (O(1))
    if visited_today.contains("ABC-123") {
        println!("The Silver Miata was here today");
    }
    println!("Total unique cars visited: {}", visited_today.len());
}
// prints
// The Silver Miata was here today
// Total unique cars visited: 3
```
- `BTreeSet` is similar to a `HashSet` in the same way that a `BTreeMap` is similar to a `HashMap`. It sorts the elements.
```rust
use std::collections::BTreeSet;

fn main() {
    let mut lot = BTreeSet::new();

    // We add cars in a completely random order
    lot.insert("XYZ-999");
    lot.insert("ABC-123");
    lot.insert("DEF-456");
    lot.insert("GHI-789");

    println!("--- Current Valet Registry (Alphabetical) ---");

    // When we iterate, they come out perfectly sorted!
    // No .sort() call required.
    for plate in &lot {
        println!("Plate: {}", plate);
    }
}
```

## BinaryHeap
- a `BinaryHeap` is a **Priority Queue**, or more simple, a `Vec` under the hood that always moves the "most important car" (the greatest value) in front of the line
- the rest of the elements are not sorted, but they are arranged in a specific *heap* structure that allows the biggest "*car*" to jump in front the moment the first one leaves
```rust
use std::collections::BinaryHeap;

fn main() {
    let mut garage = BinaryHeap::new();
    
    // adding cars to the garage with priorities
    garage.push((9, "Silver Miata"));
    garage.push((4, "Red Isuzu"));
    garage.push((5, "White Hyundai"));
    garage.push((3, "Brown Mazda 3"));
    garage.push((7, "Yellow Mercedes"));
    garage.push((10, "Ambulance"));
    
    // The Ambulance has the highest number (10), so it stays at the front.
    println!("Next car to exit: {:?}", garage.peek());
    // Output: Some((10, "Ambulance"))
    
    println!("--- Processing the queue ---");
    while let Some((priority, plate)) = garage.pop(){
        println!("Priority {}: {} is leaving.", priority, plate);
    }
}
// prints
// Next car to exit: Some((10, "Ambulance"))
// --- Processing the queue ---
// Priority 10: Ambulance is leaving.
// Priority 9: Silver Miata is leaving.
// Priority 7: Yellow Mercedes is leaving.
// Priority 5: White Hyundai is leaving.
// Priority 4: Red Isuzu is leaving.
// Priority 3: Brown Mazda 3 is leaving.
```

## VecDeque

- pronounced **vec-deck**
- it is a `Vec` that is optimized for popping items from both the front and the back of the queue
- keeping the car analogy, a `Vec` is like a dead-end parking tunnel. Popping off the back is fast and easy. You just take the last car out. But if you want to remove the car at the very front (the "entrance"), every single car behind it has to drive forward one spot to fill the gap. In computer science terms, this is an **$O(n)$** operation, meaning the more cars you have, the longer it takes
- if you need a "Drive-Through" where cars can enter and exit from *both ends* with equal speed, you use a `VecDeque` (Double-Ended Queue)
- let's see some examples. When you remove from the front of a `Vec`, every item behind it must shift left—creating a massive traffic jam
```rust
fn main() {
    let mut my_vec = vec![0; 600_000];
    for _ in 0..600000 {
        my_vec.remove(0);
    }
}
// will take a long time to run: O(n)(Slow, shifts everything)
```

```rust
use std::collections::VecDeque;
 
fn main() {
    let mut my_vec = VecDeque::from(vec![0; 600000]);
    for i in 0..600000 {
        my_vec.pop_front();
    }
}
// instant fast: O(1)(Instant, shifts nothing)
```

---  
🦀 In the next post, we will learn about the `question mark operator` and when `panic` and `unwrap` are good
