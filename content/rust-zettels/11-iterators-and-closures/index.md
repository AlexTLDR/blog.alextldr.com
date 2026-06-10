---
title: "Iterators and closures"
date: 2026-06-10
draft: false
description: "Iterators and closures enable concise, expressive, and efficient data processing in Rust"
tags:
- rust
- iterators
- closures
- methods
- consumers
- enumerate
---

- in this post, we will learn about Rust's functional style. We chain methods together so that each method's output becomes the next method's input. 
- once we get used to method chaining, we can achieve a lot with very little code
- this post will focus on **iterators** and **closures** which make this style possible and to help us better understand them, the Simpsons will be our guides

## Method chaining

- we can write Rust code as separate commands in separate lines
- let's take this example in which Homer is building his secret Duff stash
```rust
fn main() {
    // Homer wants to hide two six packs from Marge
    let mut homers_stash = Vec::new();
    let mut beer_number = 1;

    loop {
        homers_stash.push(beer_number);
        beer_number += 1;

        if beer_number > 12 {
            break;
        }
    }
    println!("Homer's beer stash counts {:?} beers", homers_stash);
}
```
- imperative style means that we give many instructions. This is what the above snioppet is. We do a lot of individual things. We start a loop, push into the `Vec` Homer is using for his secret stash, we increase the `beer_number`, we check the value of `beer_number` and break when the `berr_number` reaches the two six packs number
- the same code in functional style, requires only 2 lines of code
```rust
fn main() {
    // Homer wants to hide two six packs from Marge
    let homers_stash = (1..).take(12).collect::<Vec<i32>>();
    println!("Homer's beer stash counts {:?} beers", homers_stash);
}
```
- both snippets print:
```bash
Homer's beer stash counts [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12] beers
```
- the functional code snippet starts with a range, uses the `.take()` method to define the stop of the range and finally `collect()` creates the collection, the `::<Vec<i32>>`
- of course, the above functional example is not the most idiomatic way. It is just a way to display more functions in a row. The idiomatic way in this case would be:
```rust
fn main() {
    // Homer wants to hide two six packs from Marge
    let homers_stash = (1..=12).collect::<Vec<i32>>();
    println!("Homer's beer stash counts {:?} beers", homers_stash);
}
```
- I just used the `.take()` method to demonstrate a longer method chain
- using functional style, we can chain as many methods as we want. Also when chaining many methods, a good practice is to put each method on its own new line
- usually this is handled by `rustfmt`. Like in Go, `rustfmt` is an opinionated tool that formats your code, so all Rust code bases have the same format
```rust
fn main() {
    let duff_shelf = vec![1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

    let homers_shopping_basket = duff_shelf
        .into_iter() // 1. Homer is scanning the Duff beer shelf
        .skip(3) // 2. A wild Barney appears and snatches 3 beers from the shelf
        .take(4) // 3. Homer panics and snatches the next 4 beers from the shelf
        .collect::<Vec<i32>>(); // 4. Homer adds the 4 beers into his shopping basket

    println!(
        "Homer's shopping basket has the following beers {:?}",
        homers_shopping_basket
    );
}
// prints
// Homer's shopping basket has the following beers [4, 5, 6, 7]
```


## Iterators

- an iterator is like a collection type that outputs items one at a time. Think of a Spotify playlist. You hit play and the app plays one song at a time. You can skip 3 tracks, play the next 5 and so on 
- because we used for loops, we already used iterators. Instead of typing `for item in iterator`, we can type `for item in iterator.iter()`. A difference in the 2 ways of looping, is that the first owns the value and after the loop, the collection no longer exists and by using `.iter()`, we are getting from Rust a reference (like Bart just borrowing a comic book )
### The 3 Types of Iterators

```rust
fn main() {
    let vector1 = vec![1, 2, 3];
    let mut vector2 = vec![10, 20, 30];

    // 1. THE BART WINDOW SHOPPER
    // Gives &i32. We look at vector1, but don't consume it.
    for num in vector1.iter() {
        println!("Printing a &i32: {num}");
    }

    // 2. THE HOMER SIMPSON
    // Giving 'vector1' to a for-loop automatically calls .into_iter()
    // Gives i32. We take ownership and consume the numbers.
    // vector1 is now DEAD!
    for num in vector1 {
        // same as for donut in donuts.into_iter()
        println!("Printing an i32: {num}");
    }
    

    // 3. THE KRUSTY REBRAND
    // Gives &mut i32. We borrow vector2, but we are allowed to change the items.
    for num in vector2.iter_mut() {
        // The * is used to "dereference" the pointer so we can change the actual number
        *num *= 10;
        println!("num is now {num}");
    }

    // vector2 survived Krusty's loop, so we can still print it!
    println!("{vector2:?}");

    // ❌ ERROR! vector1 was completely eaten by the second loop.
    // println!("{vector1:?}");
}
// prints
// Printing a &i32: 1
// Printing a &i32: 2
// Printing a &i32: 3
// Printing an i32: 1
// Printing an i32: 2
// Printing an i32: 3
// num is now 100
// num is now 200
// num is now 300
// [100, 200, 300]
```

1. `.iter()` Bart reading comic books(Borrowing)
   when we write `for num in vector1.iter()`, you are asking Rust for a **reference** (`&i32`). Bart goes into the Android's Dungeon, picks up *Radioactive Man #1*, reads it, and puts it back on the shelf. He didn't buy it, and he didn't destroy it. He just **looked** at it. Because Bart only borrowed the items, `vector1` is completely safe and still exists after the loop finishes
2. `.into_iter()` - Homer eating donuts (Consuming)
   when we write `for num in vector1`, Rust secretly desugars this into `for num in vector1.into_iter()`. This gives us **ownership** (`i32`) of the actual values. Homer grabs the box of donuts, eats the first one, eats the second one, and eats the third one. The donuts are gone. They have been consumed. This is why, if we uncomment last line (`println!("{vector1:?}");`), the compiler will crash! `vector1` has been entirely digested by the second loop
3. `.iter_mut()` Krusty rebranding products (Mutating)
   When we write `for num in vector2.iter_mut()`, we are asking for a **mutable reference** (`&mut i32`). Krusty grabs a box of generic Krusty-O's from the factory belt. He doesn't take them home (he doesn't consume them), but he uses his stamp to permanently change the box (multiplying the nutrition values by 10). When he puts it back on the belt, the item survives, but it has been forever altered

- we don't need `for` to use an iterator. The same code from above can be simplified as:
```rust
fn main() {
    let vector1 = vec![1, 2, 3];
    let mut vector2 = vec![10, 20, 30];

    // 1. THE WINDOW SHOPPER (Borrowing)
    // We use .iter() to just look at the items, and .for_each() to print them.
    vector1.iter().for_each(|num| {
        println!("Printing a &i32: {num}");
    });

    // 2. THE HOMER SIMPSON (Consuming)
    // We explicitly call .into_iter() to consume the vector, passing ownership to the closure.
    // vector1 is now DEAD after this block!
    vector1.into_iter().for_each(|num| {
        println!("Printing an i32: {num}");
    });

    // 3. THE KRUSTY REBRAND (Mutating)
    // We use .iter_mut() to get mutable references, altering them inside the closure.
    vector2.iter_mut().for_each(|num| {
        *num *= 10;
        println!("num is now {num}");
    });

    // vector2 survived Krusty's pipeline, so we can still print it!
    println!("{vector2:?}");

    // ❌ ERROR! vector1 was completely eaten by Homer's .into_iter()
    // println!("{vector1:?}");
}
// prints
// Printing a &i32: 1
// Printing a &i32: 2
// Printing a &i32: 3
// Printing an i32: 1
// Printing an i32: 2
// Printing an i32: 3
// num is now 100
// num is now 200
// num is now 300
// [100, 200, 300]
```

- the methods we use with iterators are generally divided into **Adaptors** and **Consumers** 

### Iterator Adaptors

- methods like **`.map()`**, **`.filter()`**, and **`.skip()`** are called **Iterator Adaptors** 
- they take an existing iterator, modify the flow of data and return a *brand new iterator*
- there is a **catch**. They are **lazy**. If we just use `.map()` and do nothing else, nothing happens. To force the iterator to finally do the work, we must plug a consumer method like `.collect()` or `.for_each()` at the end of the chain
```rust
fn main() {
    // The raw, unfiltered list (Homer and Bart definitely added things)
    let shopping_list = vec!["Duff Beer", "Pork Chops", "Krusty-O's", "Apples"];

    // THE LAZY PIPELINE (Marge's Plan)
    // Marge is just making notes on paper. The code doesn't actually "run" yet!
    let marges_cart: Vec<String> = shopping_list
        .into_iter()
        .skip(1) // ADAPTOR: She skips the first item (Homer's beer)
        .filter(|item| *item != "Krusty-O's") // ADAPTOR: She refuses to buy sugary cereal
        .map(|item| format!("{} (Used 50% Coupon)", item)) // ADAPTOR: She prepares her coupons
        .collect(); // CONSUMER: Marge gets to the register and finally buys the items!

    println!("{:#?}", marges_cart);
}
// Prints:
// [
//     "Pork Chops (Used 50% Coupon)",
//     "Apples (Used 50% Coupon)",
// ]

```

### Consumers

- methods like `.collect()`, `.for_each()` and `.sum()` are called Consumers
- they sit at the end of the chain and "consume" the iterator to produce a final result (like a `Vec`, an `i32` or a printed message)

### The `.next()` method

- a `for` loop is an automated factory. You turn it on, and it runs until the conveyor belt is empty
- but what if we want to inspect the items manually? That is what **`.next()`** is. It is the manual override button on the conveyor belt. Every time you press `.next()`, the belt moves exactly one slot forward
- if there is a bottle, it hands you **`Some(bottle)`**, if the batch is completely finished, it hands you **`None`**
- in Rust documentation, we will see `assert_eq!` everywhere. Think of this macro as the factory's automated Quality Assurance (QA) alarm system.
```rust
fn main() {
    // A small test batch of 4 distinct beers rolls out
    let test_batch = vec!["Duff", "Duff Lite", "Duff Dry", "Fudd Beer"];

    // We put them on the belt.
    // It MUST be 'mut' because pressing .next() permanently changes the belt's state!
    let mut manual_belt = test_batch.iter();

    // The QA Alarm checks each item one by one as we press the manual button:
    assert_eq!(manual_belt.next(), Some(&"Duff")); // Matches! Silence.
    assert_eq!(manual_belt.next(), Some(&"Duff Lite")); // Matches! Silence.
    assert_eq!(manual_belt.next(), Some(&"Duff Dry")); // Matches! Silence.
    assert_eq!(manual_belt.next(), Some(&"Fudd Beer")); // Matches! Silence.

    // The batch is over. We press the button, but the belt is empty.
    assert_eq!(manual_belt.next(), None); // Expected empty. Silence.

    // We press it again just to be sure. Still empty.
    assert_eq!(manual_belt.next(), None);
}
```

### Implementing our own iterator: Moe's Tavern

- implementing `Iterator` for our own types is not too difficult. First, let’s make a struct for Moe's Tavern and think about how we might want to iterate through his stock of beers
- because of the **Orphan Rule** we learned in the `traits` post, we can’t just implement `Iterator` directly on Rust's built-in `Vec<String>`. We didn't create the `Vec` type, and we didn't create the `String` type. Instead, we have to wrap it in our own custom struct
- we will create a `FridgeStock` struct to hold the beers, and put that inside `MoesTavern`. We will also add a method to `.clone()` the stock so we can pull beers out without permanently emptying Moe's actual fridge.
```rust
#[derive(Debug)]
struct MoesTavern {
    name: String,
    stock: FridgeStock,
}

// Our custom wrapper around a Vec so we can implement Iterator on it!
#[derive(Debug, Clone)]
struct FridgeStock(Vec<String>);

impl MoesTavern {
    fn add_beer(&mut self, beer: &str) {
        self.stock.0.push(beer.to_string());
    }

    fn new(name: &str) -> Self {
        Self {
            name: name.to_string(),
            stock: FridgeStock(Vec::new()),
        }
    }

    fn get_stock(&self) -> FridgeStock {
        self.stock.clone()
    }
}
```
- how do we implement `Iterator` on this `FridgeStock` type? If we look at the standard library documentation for `Iterator`, we see two main requirements. **Required Associated Type:** `Item` and **Required Method:** `.next()`
- an **associated type** just means “a type that goes together” with the trait. Returning a `String` sounds like exactly what we want our fridge to do, so we will tell Rust that our associated type is `String`
- next, we write the `.next()` method. This is where we decide *how* our iterator behaves. For Moe's fridge, we will use `.pop()`. This means he grabs the absolute last beer that was loaded into the fridge first
```rust
impl Iterator for FridgeStock {
    // 1. The Associated Type
    type Item = String;

    // 2. The Next Method
    fn next(&mut self) -> Option<String> {
        match self.0.pop() {
            Some(beer) => {
                println!("Moe wipes a dirty glass and pours: {beer}");
                Some(beer)
            }
            None => {
                println!("We're completely dry! Somebody call Duffman!");
                None
            }
        }
    }
}

fn main() {
    let mut tavern = MoesTavern::new("Moe's Tavern");
    tavern.add_beer("Duff");
    tavern.add_beer("Duff Lite");
    tavern.add_beer("Fudd Beer");
    tavern.add_beer("Flaming Moe");

    // We can now use a for loop directly on Moe's stock!
    for drink in tavern.get_stock() {
        println!("Barney drinks: {drink}\n");
    }
}
```
- this prints:
```bash
Moe wipes a dirty glass and pours: Flaming Moe
Barney drinks: Flaming Moe

Moe wipes a dirty glass and pours: Fudd Beer
Barney drinks: Fudd Beer

Moe wipes a dirty glass and pours: Duff Lite
Barney drinks: Duff Lite

Moe wipes a dirty glass and pours: Duff
Barney drinks: Duff

We're completely dry! Somebody call Duffman!
```
- we can see that `.next()` did indeed return `None` at the very end, which triggered our secret message and cleanly stopped the `for` loop

### Infinite iterators: Professor Frink's Cloning machine

- in the Moe example, we just popped off each item until the `Vec` was empty. But we can implement an iterator in very different ways. We actually **never need to return `None`** if we want an iterator that runs forever
- let's head over to Professor Frink's lab. Here is a custom iterator that completely ignores vectors and just endlessly produces the number `1` forever
```rust
// An empty struct. It holds absolutely no data!
struct FrinkCloner;

impl Iterator for FrinkCloner {
    type Item = i32;
    
    // Notice there is no 'None' here. It just keeps giving Some(1).
    fn next(&mut self) -> Option<i32> {
        Some(1)
    }
}
```

- if we use a `for` loop on `FrinkCloner`, the program will print `1` forever until our computer crashes. But, because we are using an iterator, we can use the `.take()` method we learned earlier to safely grab exactly what we need before the machine goes out of control
```rust
fn main() {
    // We safely take 5 clones and pack them into a Vec
    let five_clones: Vec<i32> = FrinkCloner.into_iter().take(5).collect();
    
    println!("Safely captured: {five_clones:?}");
}
// Prints: [1, 1, 1, 1, 1]
```

- **note that the `FrinkCloner` struct doesn’t hold any data! It’s a brilliant example of how an iterator differs from a standard collection (like an Array or a Vec). An iterator doesn't need to store items; it only needs to know how to *produce* the next item.**

## Closures

- closures are similar to a concept to Go's anonymous functions
- instead of using `()` they use `||`
```rust
fn main() {
    let closure_example = || println!("This is a closure");
    closure_example();
}
```
- in this example, the closure takes nothing, `||` and prints the message
- between the `||` we can add input variables as in a normal function
```rust
fn main() {
    let duff_beers_sixpacks = |x: u8| println!("The number of Duff beers is {}", x / 6);
    duff_beers_sixpacks(6 + 6);
}
// prints
// The number of Duff beers is 2
```
- for longer closures, we need to use code blocks
```rust
fn main() {
    let total_duffs = || {
        let homer_duffs = 10;
        let barney_duffs = 3;
        let lenny_duffs = 5;
        println!(
            "The boys have a total number of {} Duffs ",
            homer_duffs + barney_duffs + lenny_duffs
        );
    };
    total_duffs();
}
// prints
// The boys have a total number of 18 Duffs
```
- one special quirk of closures, is that they can take variables from outside the closure
```rust
fn main() {
    let homer_duffs = 10;
    let barney_duffs = 3;
    let lenny_duffs = 5;
    let total_duffs = || {
        println!(
            "The boys have a total number of {} Duffs ",
            homer_duffs + barney_duffs + lenny_duffs
        );
    };
    total_duffs();
}
```
- strictly semantic, `||` that doesn't use outside variables is called an *anonymous function* and `|x: u8|` which takes one or more variables, is called a *closure* . But people usually refer to both as *closures*

### Closures inside of methods

- most often, closures are used within methods
- we have already seen closures in methods in the iteration part of the post, for example in the *Iterator Adaptors* example
```rust
let marges_cart: Vec<String> = shopping_list
        .into_iter()
        .skip(1) // ADAPTOR: She skips the first item (Homer's beer)
        .filter(|item| *item != "Krusty-O's") // ADAPTOR: She refuses to buy sugary cereal
        .map(|item| format!("{} (Used 50% Coupon)", item)) // ADAPTOR: She prepares her coupons
        .collect(); // CONSUMER: Marge gets to the register and finally buys the items!
```
- below an example in which we can write the body of the closure different each time, as long as the signature matches
```rust
fn main() {
    (1..=3).for_each(|bottle_num| println!("Barney chugs bottle #{bottle_num}!"));

    (1..4).for_each(|bottle_num| {
        println!("Homer inspects bottle #{bottle_num}...");
        if bottle_num % 2 == 0 {
            println!("  -> It's an even number! Perfect classic Duff.")
        } else {
            println!("  -> It's an odd number! Ugh, it's a Duff Lite.")
        }
    });
}
// prints
// Barney chugs bottle #1!
// Barney chugs bottle #2!
// Barney chugs bottle #3!
// Homer inspects bottle #1...
//   -> It's an odd number! Ugh, it's a Duff Lite.
// Homer inspects bottle #2...
//   -> It's an even number! Perfect classic Duff.
// Homer inspects bottle #3...
//   -> It's an odd number! Ugh, it's a Duff Lite.
```

### `.unwrap_or_else()`

- another cool method that works with closures, is `.unwrap_or_else()`. This is a useful method as it allows us to pass a closure as the default value
```rust
fn main() {
    // Lisa has 3 Bleeding Gums Murphy albums (volumes 1, 2, and 3)
    let jazz_records = vec![1, 2, 3];

    // She reaches for the 4th album (index 3).
    // It doesn't exist! So .unwrap_or_else() triggers the backup closure.
    let fallback_record = jazz_records.get(3).unwrap_or_else(|| {
        println!("Album 4 is missing! Activating Lisa's backup plan...");

        // Backup Plan A: Try to grab the 3rd album (index 2) instead
        if let Some(record) = jazz_records.get(2) {
            println!("Found Album 3! We are saved.");
            record
        } else {
            // Backup Plan B: If Bart stole the whole collection, play track 0
            println!("Everything is gone. Playing standard scale practice.");
            &0
        }
    });

    println!("Lisa is currently playing: {}", fallback_record);
}
// prints
// Album 4 is missing! Activating Lisa's backup plan...
// Found Album 3! We are saved.
// Lisa is currently playing: 3
```

### `.enumerate`

- when you just want the data, a standard iterator works fine. But when you need to know exactly *where* that data is in the line, `.enumerate()` is the perfect tool
- let’s say Chief Wiggum is looking at a police lineup of Springfield's worst criminals. A standard iterator will just hand him `Some("Snake")`, then `Some("Sideshow Bob")`, and finally `Some("Fat Tony")`
- but what if Wiggum needs to fill out the police paperwork and wants to see the **exact suspect number (the index)** along with the criminal's name?
- it turns out that all you have to do is add `.enumerate()` to the iterator. This automatically pairs every item with its index, handing you a neat little tuple: `(index, item)`
```rust
fn main() {
    // The criminals standing against the wall
    let lineup = vec!["Snake", "Sideshow Bob", "Fat Tony"];

    // THE PAPERWORK PIPELINE
    lineup
        .iter()
        .enumerate() // ADAPTOR: Attaches a number (0, 1, 2...) to each item!
        .for_each(|(suspect_number, criminal)| {
            // Because of .enumerate(), our worker closure now takes a tuple!
            println!("Suspect #{suspect_number} is: {criminal}");
        });
}
// prints
// Suspect #0 is: Snake
// Suspect #1 is: Sideshow Bob
// Suspect #2 is: Fat Tony
```

### `|_|` in a closure

- `|_|` in a closure means that the closure needs to take an argument that is named (like the tuple `(suspect_number, criminal)` in our last example ) but we don't want to use it
- let's use Maggie at the end of the post. The family is handing Maggie different toys, but she doesn't care what they are. She is just going to suck her pacifier anyway
```rust
fn main() {
    let toys = vec!["Blocks", "Teddy Bear", "Rattle"];

    // ❌ ERROR! .for_each() is trying to hand Maggie a toy, 
    // but her closure has no hands `||` to accept it!
    toys.iter().for_each(|| println!("*Maggie sucks pacifier*"));
}
```
- if we run this code, we will get the below error in which the compiler teaches us how to fix the issue
```bash
error[E0593]: closure is expected to take 1 argument, but it takes 0 arguments
 --> src/main.rs:6:17
  |
6 |     toys.iter().for_each(|| println!("*Maggie sucks pacifier*"));
  |                 ^^^^^^^^ -- takes 0 arguments
  |                 |
  |                 expected closure that takes 1 argument
  |
help: consider changing the closure to take and ignore the expected argument
  |
6 |     toys.iter().for_each(|_| println!("*Maggie sucks pacifier*"));
  |                           +

For more information about this error, try `rustc --explain E0593`.
error: could not compile `tmp` (bin "tmp") due to 1 previous error
```

---  
🦀 In the next post, we will learn more about closures and iterators 😬, we will take a look at some of the most common methods for iterators and closures
