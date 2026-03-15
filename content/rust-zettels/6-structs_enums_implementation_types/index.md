---
title: "Structs, Enums, and Implementation types"
date: 2026-03-15
draft: false
description: "Structs, Enums, and Implementation types in Rust."
tags:
- rust
- structs
- enums
- methods
- references
- dot operator
- destructuring
---

# Blueprint to Behavior: Structs, Enums, and Implementation

- structs and enums are similar in syntax, and they work together
- structs can contain enums and vice versa
- as in Go, structs are used to group values to build your own types
- enums, which are missing from Go 😑, are used for choices and not grouping values
- best way to differentiate when to use structs and enums is by need. If you need to group things together, use structs. If you need to select a choice from more options, use enums
- a book that has a title (string), an author (string), and other fields like number of pages (int) is a struct
- the same book can be bought as paper print or as a Kindle edition, that's an enum (when you choose which format to buy)

## Structs

- structs are created with the key word `struct` followed by its name
- it is idiomatic to name the structs with upper camel case
```rust
struct AdminUser;
```
- there are 3 types of structs, `unit struct`, `tuple struct` and `named struct`

### Unit struct
- this is the `AdminUser` struct from above. This means that it is an empty struct, similar to Go's empty structs
- it is called a `unit struct` because, similar to the `unit type` (discussed in the Arrays post, an empty tuple) it doesn't contain anything

### Tuple struct (unnamed struct)
- it is called unnamed because we just write the tuple types, and we don't name the fields
- this is useful for simple structs and to avoid bothering with names
```rust
struct Location(String, String, String);  
fn main() {  
    let destination = Location(  
        String::from("Bucharest"),  
        String::from("Romania"),  
        String::from("Ro"),  
    );  
    // Usage via index  
    println!("The destination city is {}", destination.0);  
  
    // Usage via destructuring  
    let Location(city, country, _) = destination;  
    println!(  
        "We are going to {} which is the capital of {}",  
        city, country  
    );  
}
```
- below is the result with the warning that the 3rd `String` is never used in the `Location` struct
```bash
cargo run
   Compiling tmp v0.1.0 (/home/alex/github.com/tmp_stuff/rust/tmp)
warning: field `2` is never read
 --> src/main.rs:1:33
  |
1 | struct Location(String, String, String);
  |        --------                 ^^^^^^
  |        |
  |        field in this struct
  |
  = help: consider removing this field
  = note: `#[warn(dead_code)]` (part of `#[warn(unused)]`) on by default

warning: `tmp` (bin "tmp") generated 1 warning
    Finished `dev` profile [unoptimized + debuginfo] target(s) in 0.17s
     Running `target/debug/tmp`
The destination city is Bucharest
We are going to Bucharest which is the capital of Romania
```

### Named struct
- this is the most common struct
- in this struct, we declare the field names and types inside a code block `{}`
```rust
struct Destination {  
    city: String,  
    country: String,  
    airport_code: String,  
    population: u32,  
    is_capital: bool,  
}  
  
fn main() {  
    let bucharest = Destination {  
        city: String::from("Bucharest"),  
        country: String::from("Romania"),  
        airport_code: String::from("OTP"),  
        population: 2_000_000,  
        is_capital: true,  
    };  
    // Accessing data with the dot operator  
    println!(  
        "It is {} that {} is the capital of {} and the airport code is {}",  
        bucharest.is_capital, bucharest.city, bucharest.country, bucharest.airport_code  
    );  
  
    // Destructuring the struct  
    let Destination {  
        city, population, ..  
    } = bucharest;  
    println!("{}'s population is {}", city, population);  
}
// It is true that Bucharest is the capital of Romania and the airport code is OTP
// Bucharest's population is 2000000
```
- the same code from above can be re-written like so
```rust
struct Destination {  
    city: String,  
    country: String,  
    airport_code: String,  
    population: u32,  
    is_capital: bool,  
}  
  
fn main() {  
    let city = String::from("Bucharest");  
    let country = String::from("Romania");  
    let airport_code = String::from("OTP");  
    let population = 2_000_000;  
    let is_capital = true;  
  // if the field name and variable name are the same
  // you don't have to write them both
    let bucharest = Destination {  
        city: city,  
        country: country,  
        // this is called the short hand initializer
        airport_code,  
        population,  
        is_capital: is_capital,  
    };  
    println!(  
        "It is {} that {} is the capital of {} and the airport code is {}",  
        bucharest.is_capital, bucharest.city, bucharest.country, bucharest.airport_code  
    );  
  
    // Destructuring the struct  
    let Destination {  
        city, population, ..  
    } = bucharest;  
    println!("{}'s population is {}", city, population);  
}
```
- in the above example, we are constructing the `bucharest variable` that holds an instance of the `Destination` struct
- I wanted to point out, that if the field name and variable name are the same, you can either write for example the city field as `city: city,` or simply `city,` . This is called the shorthand initializer 
- we don't put a `;` after named structs 
- fields in the structs are comma separated. After the last field the comma is optional
- I like to add the comma after the last field as the whole looks more consistent (and looks more Go like)
- another use case for adding the last comma is if you ever decide to switch the order of the fields and use copy - paste 

## Enums

- they look very similar to `structs` but are used to choose from one or another thing
- we declare `enums` just like `structs` but with the `enum` keyword
- besides that, the same rules with the comma at the end apply
```rust
#[derive(Debug)] // this implements "Display" required for printing  
enum Region {  
    Europe,  
    Asia,  
    Americas,  
    Africa,  
    Oceania,  
}  
  
struct Destination {  
    city: String,  
    country: String,  
    airport_code: String,  
    population: u32,  
    is_capital: bool,  
    region: Region,  
}  
  
  
fn main() {  
    let city = String::from("Bucharest");  
    let country = String::from("Romania");  
    let airport_code = String::from("OTP");  
    let population = 2_000_000;  
    let is_capital = true;  
  
    let bucharest = Destination {  
        city,  
        country,  
        airport_code,  
        population,  
        is_capital,  
        region: Region::Europe,  
    };  
    println!(  
        "It is {} that {} is the capital of {}, which is in {:?} and the airport code is {}",  
        bucharest.is_capital, bucharest.city, bucharest.country, bucharest.region ,bucharest.airport_code  
    );  
  
    // Destructuring the struct  
    let Destination {  
        city, population, ..  
    } = bucharest;  
    println!("{}'s population is {}", city, population);  
}
```
- to our previous `struct` code, we have added an `enum`, region 
- we have already learned from the printing post, that using `{:?}` we can `Debug print`
- because the `Region` enum doesn't implement the `Debug` trait by default, we use `#[derive(Debug)]` to tell the compiler to automatically generate the code required to print it
- let's simplify things 😆:
```rust
enum MemoryType {  
    GarbageCollected,  
    Manual,  
    Ownership,  
}  
enum Language {  
    Rust(MemoryType),  
    Go(MemoryType),  
    C(MemoryType),  
}  
  
fn check_languages(lang: Language) {  
    match lang {  
        Language::Rust(mem) => match mem {  
            MemoryType::Ownership => println!("Rust uses ownership: No GC needed"),  
            _ => println!("This isn't ownership of Rust"),  
        },  
        Language::Go(_) => println!("Go is garbage collected"),  
        Language::C(mem) => match mem {  
            MemoryType::Manual => {  
                println!("In C the developer manually allocates and deallocate memory")  
            }  
            _ => println!("This isn't manual allocation of C"),  
        },  
    }  
}  
  
fn main() {  
    let my_first_lang = Language::Go(MemoryType::GarbageCollected);  
    let my_second_lang = Language::Rust(MemoryType::Ownership);  
    let i_should_learn = Language::C(MemoryType::GarbageCollected);  
    check_languages(my_first_lang);  
    check_languages(my_second_lang);  
    check_languages(i_should_learn);  
}
// prints:
// Go is garbage collected
// Rust uses ownership: No GC needed
// This isn't manual allocation of C
```
- **it also prints some warnings that we are not reading all the fields and we are not constructing all the variants, but these are not important:** 
1. **Data Modeling with Enums**: instead of using a simple list of names, we use **Data-Bearing Enums**. The `Language` enum doesn't just say "Rust"; it carries a `MemoryType` inside it. This allows us to group related information together in a single, type-safe package
2. **Binding vs. Ignoring Data**: *for Go* we used `Language::Go(_)`. The underscore is the "ignore" pattern. It tells Rust: "I know there is data here, but I don't need it for this logic." *For C and Rust* we used `Language::C(mem)`. By giving it a name (`mem`), we **bind** the internal data to a variable so you can use it immediately in a nested match
3. **Exhaustive Nested Matching**: the `check_languages` function shows how to "peel the onion." By performing a **nested match**, we can verify if the internal data matches our expectations. Because Rust requires matches to be **exhaustive**, we must provide a catch-all (`_`) for the "impossible" cases, like the example where C is paired with a *Garbage Collector*. This ensures the program always has a clear path forward, even with weird data combinations. **Note:** In both the **Rust** and **C** cases, `mem` is a variable we created on the fly. It only exists inside those specific arms of the match block! This is called "binding," and it's a safe way to access temporary data only when we actually need it
- `enums` can also hold data:
```rust
struct Version {  
    version: String,  
    is_rc: bool,  
}  
  
#[derive(Debug)]  
enum MemoryType {  
    GarbageCollected,  
    Manual,  
    Ownership,  
}  
  
enum Language {  
    Rust(Version, MemoryType),  
    Go(Version, MemoryType),  
    C(Version, MemoryType),  
}  
  
fn check_language(lang: Language) {  
    match lang {  
        Language::Rust(v, m) => {  
            println!("Rust {} (RC: {}) uses {:?}", v.version, v.is_rc, m);  
        }  
        Language::Go(v, m) => {  
            println!("Go {} (GO: {}) uses {:?}", v.version, v.is_rc, m);  
        }  
        Language::C(v, m) => {  
            println!("C {} (CC: {}) uses {:?}", v.version, v.is_rc, m);  
        }  
    }  
}  
fn main() {  
    let rust = Language::Rust(  
        Version {  
            version: String::from("1.94.0"),  
            is_rc: false,  
        },  
        MemoryType::Ownership,  
    );  
    check_language(rust);  
}
// prints
Rust 1.94.0 (RC: false) uses Ownership
```
- in this example, we use `nesting` in `Language::Rust`. This variant is holding two completely different types of data: a **Struct** (`Version`) and another **Enum** (`MemoyType`)
- we use `stateful variants` when we create `rust` in `main()`, we aren't just saying "This is Rust." We are attaching a specific version string (`"1.94.0"`) and a specific boolean (`false`) to that instance
- and we also handle `pattern matching with data` in the `match` block. By writing `Language::Rust(v, m)` we **destructure**. We are giving names (`v` and `m`) to the data in the `enum`, and we then use these names
- a little `variable scope` reminder: even though `v` and `m` are used in the `println!`, they are "born" inside the `match` arm. If we tried to use `v` outside of that specific `match` case, the code wouldn't compile

### The `use` keyword
- enums have a life hack with the `use` keyword
```rust
struct Version {  
    version: String,  
    is_rc: bool,  
}  
  
#[derive(Debug)]  
enum MemoryType {  
    GarbageCollected,  
    Manual,  
    Ownership,  
}  
  
enum Language {  
    Rust(Version, MemoryType),  
    Go(Version, MemoryType),  
    C(Version, MemoryType),  
}  
// the "*" brings all variants  
// no need for use Language::{Rust, Go, C}  
use Language::*;  
use MemoryType::*;  
  
fn check_language(lang: Language) {  
    match lang {  
        // no more "Language::" prefix needed  
        Rust(v, m) => {  
            println!("Rust {} (RC: {}) uses {:?}", v.version, v.is_rc, m);  
        }  
        Go(v, m) => {  
            println!("Go {} (GO: {}) uses {:?}", v.version, v.is_rc, m);  
        }  
        C(v, m) => {  
            println!("C {} (CC: {}) uses {:?}", v.version, v.is_rc, m);  
        }  
    }  
}  
fn main() {  
    // we can use Rust and Ownership directly here too because of the 'use' above  
    let rust = Rust(  
        Version {  
            version: String::from("1.94.0"),  
            is_rc: false,  
        },  
        Ownership,  
    );  
    check_language(rust);  
}
```
- by modifying the previous code, it is clearly shown how `use` can help us to simplify our code
- **very important, the `use` keyword can be used for other imports as well so we don't need to write the whole import path everytime**
- we can also cast `enums` into `integers`:
```rust
enum Status {  
    Active,  
    Inactive,  
    Pending,  
}  
  
fn main() {  
    let my_status = Status::Active;  
  
    // casting to int using "as"  
    let status_number = my_status as i32;  
    println!("Status number is {}", status_number);  
}
// prints
// Status number is 0
```
- we can also assign whatever numbers we want:
```rust
enum Status {  
    Active = 10,  
    Inactive = 20,  
    Pending = 30,  
}  
  
fn main() {  
    let my_status = Status::Active;  
  
    // casting to int using "as"  
    let status_number = my_status as i32;  
    println!("Status number is {}", status_number);  
}
// prints
// Status number is 10
```
- we can use multiple types with enums:
```rust
enum Number {  
    U32(u32),  
    I32(i32),  
    Float(f64),  
}  
  
fn process_number(num: Number) {  
    match num {  
        Number::U32(value) => println!("It's a positive only int {}", value),  
        Number::I32(value) => println!("It's a negative only int {}", value),  
        Number::Float(value) => println!("It's a float {}", value),  
    }  
}  
  
fn main() {  
    let positivive = Number::U32(100);  
    process_number(positivive);  
    let negative = Number::I32(-1);  
    process_number(negative);  
    let float = Number::Float(1.1);  
    process_number(float);  
}
// prints
// It's a positive only int 100
// It's a negative only int -1
// It's a float 1.1
```
- in the above code, we have 3 variants. The `U32` with an `u32` inside, the `I32` with an `i32` and the `Float` with an `f64`. They are name type pairs. We could have used `Unsigned` instead of `U32`

### `impl` for implementing structs and enums
- it is used for writing functions for `structs` and `enums`. This is the exact concept from Go, where we define `methods` on a `struct` 
- Go:
```go
type Version struct {
    Number string
    IsRC   bool
}

// method with a receiver
func (v Version) IsStable() bool {
    return !v.IsRC
}
```
- Rust
```rust
struct Version {
    number: String,
    is_rc: bool,
}

// the implementation block
impl Version {
    // "self" is like the receiver in Go
    fn is_stable(&self) -> bool {
        !self.is_rc
    }
}
```
- if a function in the `impl` block uses `self`, `&self` or `&mut self` it is called a method (like above)
- there are also *associated functions* that don't take `self` (or any other form of `self`). They are called differently, by typing `::` between the type name and the func name.  Perfect examples are from what we already used, `String::from()` or `Vec::new()` 
- let's make a bigger `enum` block. Since this is my blog and I like cars, the below example is like choosing between a gas or a diesel engine
```rust
#[derive(Debug)]  
enum EngineType {  
    Gas,  
    Diesel,  
}  
  
#[derive(Debug)]  
struct Car {  
    model: String,  
    engine: EngineType,  
}  
  
impl Car {  
    // 1. constructor: start with a gas engine  
    fn new_gas(model_name: &str) -> Self {  
        Self {  
            model: model_name.to_string(),  
            engine: EngineType::Gas,  
        }  
    }  
  
    // 2. read-only: check the current state  
    fn check_engine(&self) {  
        match self.engine {  
            EngineType::Gas => println!("The {} is a gas car.", self.model),  
            EngineType::Diesel => println!("The {} is a diesel truck", self.model),  
        }  
    }  
  
    // 3. mutable: swap the state to diesel  
    fn convert_to_diesel(&mut self) {  
        self.engine = EngineType::Diesel;  
        println!(  
            "Swapped {} to Diesel! Current state: {:?}",  
            self.model, self  
        );  
    }  
  
    // 4. mutable: swap the state to gas  
    fn convert_to_gas(&mut self) {  
        self.engine = EngineType::Gas;  
        println!("Swapped {} to Gas! Current state: {:?}", self.model, self);  
    }  
}  
  
fn main() {  
    // 'mut' is the key here!  
    let mut my_car = Car::new_gas("Mazda 3");  
  
    my_car.check_engine();  
  
    // changing state to diesel  
    my_car.convert_to_diesel();  
    my_car.check_engine();  
  
    // changing it back to gas  
    my_car.convert_to_gas();  
    my_car.check_engine();  
}
// prints
// The Mazda 3 is a gas car.
// Swapped Mazda 3 to Diesel! Current state: Car { model: "Mazda 3", engine: Diesel }
// The Mazda 3 is a diesel truck
// Swapped Mazda 3 to Gas! Current state: Car { model: "Mazda 3", engine: Gas }
// The Mazda 3 is a gas car.
```
- **`Self` (Capital S):** This refers to the **Type** we are currently implementing. In this block, whenever you see `Self`, you can mentally replace it with `Car`
    - _Example:_ `fn new_gas(...) -> Self` is just a shorter way of saying `fn new_gas(...) -> Car`
- **`self` (Lowercase s):** This refers to the specific **instance** (the actual object) you are working with. It’s like the "receiver" in Go or `this` in JavaScript.
- **`&mut self`:** This is the most important part of the state-swap. When you write `fn convert_to_diesel(&mut self)`, Rust sees it as **`fn convert_to_diesel(self: &mut Car)`**
- like we already learned in the [Arrays, Vectors and Tuples](https://blog.alextldr.com/rust-zettels/4-arrays-vectors-and-tupels/) section, we can *destructure* a `struct` or an `enum`
```rust
struct Player {  
    name: String,  
    goals: u32,  
}  
  
enum Position {  
    Striker(Player),  
    Goalkeeper(Player, u8), // player info + clean sheets  
}  
  
fn main() {  
    let s_player = Position::Striker(Player {  
        name: String::from("Messi"),  
        goals: 800,  
    });  
  
    // DESTRUCTURING: we "reach in" to grab the Player struct 'p'  
    match s_player {  
        Position::Striker(p) => {  
            println!("The Striker {} has scored {} goals!", p.name, p.goals);  
        }  
        Position::Goalkeeper(p, sheets) => {  
            println!("The Keeper {} has {} clean sheets!", p.name, sheets);  
        }  
    }  
}
```
-and finally for this post, we have `references` and the `dot operator`
```rust
struct Player {  
    name: String,  
    jersey_number: u8,  
}  
  
fn main() {  
    let striker = Player {  
        name: String::from("Harry Kane"),  
        jersey_number: 9,  
    };  
  
    // 1. create a reference to the player (the "scout's notes")  
    let scout_reference = &striker;  
  
    // 2. the Dot Operator in action  
    // we don't have to do (*scout_reference).name.    // we just use the dot!    println!(  
        "Scouting report: {} wears number {}.",  
        scout_reference.name, scout_reference.jersey_number  
    );  
}
```

---  
🦀 In the next post, we will cover generics, option and result
