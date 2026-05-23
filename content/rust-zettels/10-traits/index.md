---
title: "Traits: Shared Skills for Different Types"
date: 2026-05-23
draft: false
description: "Traits: Shared Skills for Different Types"
tags:
- rust
- traits
- Debug
- Display
- Self
- std::fmt
- bounds
- From
- orphan rule
- NewType Idiom
- String
---

- for the gopher readers, traits are the interfaces of Rust. They solve the same problem, they allow you to write generic, flexible code based on **what a type can do**, rather than what a type **is**.
- `Debug`, `Copy` and `Clone` are traits that we are already used to
- with traits, you can empower types to do things they couldn't do before
- **a trait guarantees to the compiler that it can do something, no matter what type it is**
- to give a trait, you have to implement the trait for the type
- a way to implement traits is through attributes, to implement traits like `Debug`. These are so common that Rust uses this special syntax, `#[derive(Debug)]`, to automatically implement the `Debug` trait:

```rust
// The derive attribute automatically writes the Debug trait for us
#[derive(Debug)]
struct Weapon {
    name: String,
    damage: u8,
    is_magical: bool,
}

fn main() {
    let my_sword = Weapon {
        name: String::from("Iron Longsword"),
        damage: 15,
        is_magical: false,
    };
    // The Guild Master inspects the weapon using {:?}
    println!("Guild Log: {:?}", my_sword);
    // Or nicely formatted with {:#?}
    println!("Detailed Log: {:#?}", my_sword);
}
```
- and this prints:

```bash
Guild Log: Weapon { name: "Iron Longsword", damage: 15, is_magical: false }
Detailed Log: Weapon {
    name: "Iron Longsword",
    damage: 15,
    is_magical: false,
}
```
- other traits are more difficult for the compiler to guess, so we need to implement them manually with the `impl` keyword and define them with the `trait` keyword

```rust
// 1. We define the Trait (The Contract)
// Anyone who signs this MUST have an 'attack' method that returns a String.
trait Attack {
    fn attack(&self) -> String;
}

// 2. We define the structs that will implement the Trait
struct Warrior {
    name: String,
    weapon: String,
}

struct Mage {
    name: String,
    mana: u8,
}

// 3. The Warrior "signs" the contract
impl Attack for Warrior {
    fn attack(&self) -> String {
        format!(
            "{} swings their {} with fierce power!",
            self.name, self.weapon
        )
    }
}

// 4. The Mage signs the contract
impl Attack for Mage {
    fn attack(&self) -> String {
        if self.mana > 10 {
            format!("{} casts a fireball", self.name)
        } else {
            format!("{} is out of mana and uses his staff as a club", self.name)
        }
    }
}

fn main() {
    let gimli = Warrior {
        name: String::from("Gimli"),
        weapon: String::from("Great Axe"),
    };

    let gandalf = Mage {
        name: String::from("Gandalf"),
        mana: 5,
    };
    // 5. Both characters can now use the attack() method
    println!("Warrior action: {}", gimli.attack());
    println!("Mage action: {}", gandalf.attack());
}
// prints
// Warrior action: Gimli swings their Great Axe with fierce power!
// Mage action: Gandalf is out of mana and uses his staff as a club
```
- when writing a trait, use a default method if most structs will share the same behavior. It is like every character has an ability to fight with their fists, regardless of race, class and equipment. If every struct needs to behave differently, just write the **signature** to force them to build their own custom logic. The best part is that defaults are not prisons. Any character can swap out the base attack, let's say, from fists to kicks, by simply overriding the method

```rust
// 1. The Trait with a Default Method
trait Attack {
    fn attack(&self) -> String {
        // This is the default base attack: fists!
        String::from("throws a punch with his bare fists!")
    }
}

struct Hobbit {
    name: String,
}

struct UrukHai {
    name: String,
}

// 2. The Hobbit accepts the default
// By leaving the block completely empty, Pippin gets the default fist attack.
impl Attack for Hobbit {}

// 3. The Uruk-Hai OVERRIDES the default
// By writing the method signature again, Lurtz throws away the fists 
// and replaces it with his own custom kicking logic.
impl Attack for UrukHai {
    fn attack(&self) -> String {
        format!("{} delivers a brutal, heavy-booted front kick!", self.name)
    }
}

fn main() {
    let pippin = Hobbit {
        name: String::from("Pippin"),
    };

    let lurtz = UrukHai {
        name: String::from("Lurtz"),
    };

    println!("Hobbit action: {} {}", pippin.name, pippin.attack());
    println!("Uruk-Hai action: {}", lurtz.attack());
}
// prints
// Hobbit action: Pippin throws a punch with his bare fists!
// Uruk-Hai action: Lurtz delivers a brutal, heavy-booted front kick!
```
- so now that we know how to `impl` a trait, we can check again the first example of the post, to see how to implement *someone else's trait*
- we can see the `Debug` trait in action, being able to pretty print by using the `:#?` syntax
- we can also use the `Display` trait to pretty print (below the first code example but with `Display`)

```rust
use std::fmt; // We must bring the formatting tools into scope

struct Weapon {
    name: String,
    damage: u8,
    is_magical: bool,
}

// We explicitly implement the Display contract for Weapon
impl fmt::Display for Weapon {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let magic_str = if self.is_magical {
            "Magically forged weapon"
        } else {
            "Standard forged weapon"
        };
        // write! works exactly like format!, but it pushes the string
        // directly into the formatter (f) instead of making a new String.
        write!(f, "🗡️ {} [DMG: {}] - {}", self.name, self.damage, magic_str)
    }
}

fn main() {
    let my_sword = Weapon {
        name: String::from("Iron Lonsword"),
        damage: 15,
        is_magical: false,
    };
    // standard {} without the Debug trait
    println!("Player inventory: {}", my_sword);
}
// Prints
// Player inventory: 🗡️ Iron Lonsword [DMG: 15] - Standard forged weapon
```
- sometimes implementing a trait gives us extra traits. Like the `Display` trait gives us the `.to_string()` method, that we have already used in previous posts of the series

```rust
use std::fmt;

struct Weapon {
    name: String,
    damage: u8,
    is_magical: bool,
}

// We explicitly implement the Display contract for Weapon
impl fmt::Display for Weapon {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        let magic_str = if self.is_magical {
            "Magically forged weapon"
        } else {
            "Standard forged weapon"
        };
        // write! works exactly like format!, but it pushes the string
        // directly into the formatter (f) instead of making a new String.
        write!(f, "🗡️ {} [DMG: {}] - {}", self.name, self.damage, magic_str)
    }
}

// Let's pretend this is a function that saves data to the game's database.
// It strictly requires a fully-owned String, NOT a Weapon struct.
fn save_to_database(data: String) {
    println!("Database saved: {}", data)
}

fn main() {
    let my_sword = Weapon {
        name: String::from("Iron Lonsword"),
        damage: 15,
        is_magical: false,
    };
    // Use Case A: Printing it directly (Uses Display)
    println!("Inventory UI: {}", my_sword);

    // Use Case B: THE FREE TRICK (Uses ToString)
    // We can call .to_string() directly on the struct!
    let sword_string = my_sword.to_string();

    // Now we can pass that newly created String to our database function
    save_to_database(sword_string);
}
// Prints
// Inventory UI: 🗡️ Iron Lonsword [DMG: 15] - Standard forged weapon
// Database saved: 🗡️ Iron Lonsword [DMG: 15] - Standard forged weapon
```
- traits are about the shared behavior of something. How does the struct or enum act? How can we show that other types have the same behavior? As example, `Copy`, `Display`, `ToString`, etc are just about what a type can do

## Trait Bounds

- a trait bound is a strict prerequisite for a generic type. It is how Rust is telling the compiler that it will accept any type of object here if it has *signed* this specific *trait contract* first
- when we write a generic function, the compiler is strict. If we give a generic type `T`, it assumes `T` can do absolutely nothing. With **trait bounds** we grant to the generic type `T` it's abbilities

```rust
trait SpeakElvish {
    fn say_friend(&self) -> String;
}

struct Wizard {
    name: String,
}

struct Dwarf {
    name: String,
}

impl SpeakElvish for Wizard {
    fn say_friend(&self) -> String {
        String::from("Mellon") // the Elvish word for friend
    }
}
// THE TRAIT BOUND
// <T: SpeakElvish> means: "I will accept ANY type T, 
// but only if T has signed the SpeakElvish contract."
fn open_moria_doors<T: SpeakElvish>(speaker: &T) {
    println!(
        "The speaker steps to the door and says: {}",
        speaker.say_friend()
    );
    println!("The magic doors swing open...\n")
}

fn main() {
    let gandalf = Wizard {
        name: String::from("Gandalf"),
    };

    let gimli = Dwarf {
        name: String::from("Gimli"),
    };

    println!("--- Attempting to enter Moria ---");

    open_moria_doors(&gandalf);
}
// Prints
// --- Attempting to enter Moria ---
// The speaker steps to the door and says: Mellon
// The magic doors swing open...
```
- in **The Moria Doors** example, the lock is on a function, `fn open_moria_doors<T: SpeakElvish>` . By locking at this specific piece of code, we are telling the compiler, "*Anyone can exist in the game but only who speaks Elvish can open_moria_doors*"

```rust
use std::fmt::Debug;

struct UrukHai {
    health: i32,
}

#[derive(Debug)]
struct Wizard {
    name: String,
    health: i32,
}

#[derive(Debug)]
struct Ranger {
    name: String,
    health: i32,
}

trait MeleeCombat: Debug {
    fn strike_with_sword(&self, enemy: &mut UrukHai) {
        enemy.health -= 15;
        println!(
            "Sword strike! Uruk-Hai Health: {}. Hero status {:?}",
            enemy.health, self
        )
    }

    fn strike_with_staff(&self, enemy: &mut UrukHai) {
        enemy.health -= 5;
        println!(
            "Staff blow! Uruk-Hai health: {}. Hero status {:?}",
            enemy.health, self
        );
    }
}

impl MeleeCombat for Wizard {}
impl MeleeCombat for Ranger {}

trait RangedCombat: Debug {
    fn arrow(&self, enemy: &mut UrukHai, distance: u32) {
        if distance < 50 {
            enemy.health -= 20;
            println!(
                "Arrow flies! Uruk-Hai health: {}. Hero status: {:?}",
                enemy.health, self
            );
        } else {
            println!("The Uruk-Hai is out of range!");
        }
    }
}

impl RangedCombat for Ranger {}

fn main() {
    let gandalf = Wizard {
        name: String::from("Gandalf"),
        health: 100,
    };

    let aragon = Ranger {
        name: String::from("Aragon"),
        health: 69,
    };

    let mut lurtz = UrukHai { health: 120 };

    println!("--- The battle begins ---");
    gandalf.strike_with_staff(&mut lurtz);
    aragon.arrow(&mut lurtz, 20);
}
// Prints
// --- The battle begins ---
// Staff blow! Uruk-Hai health: 115. Hero status Wizard { name: "Gandalf", health: 100 }
// Arrow flies! Uruk-Hai health: 95. Hero status: Ranger { name: "Aragon", health: 69 }

```
- in **The Combat** example, the lock is on the trait itself (**A Supertrait**). `trait MeleeCombat: Debug` is telling the compiler that it doesn't care what function the object try to run, but without the `Debug` certification (the `#[derive(Debug)]` above the structs) the code won't compile

## Marker traits or traits as bounds

- let's rewrite the last example using **Empty Traits(Marker Traits)** 
- these traits exist just to be used as a tag, so that other standalone functions know who is allowed in. Like passing an exam. You need to pass the Driving exam in order to get a driver's license and drive a car
```rust
use std::fmt::Debug;

struct UrukHai {
    health: i32,
}

#[derive(Debug)]
struct Wizard {
    name: String,
    health: i32,
}

#[derive(Debug)]
struct Ranger {
    name: String,
    health: i32,
}

trait MeleeCombat: Debug {}
trait RangedCombat: Debug {}

impl MeleeCombat for Wizard {}
impl MeleeCombat for Ranger {}

impl RangedCombat for Ranger {}

fn strike_with_staff<T: MeleeCombat>(attacker: &T, enemy: &mut UrukHai) {
    enemy.health -= 15;
    println!(
        "Staff strike! Uruk-Hai Health: {}. Hero status {:?}",
        enemy.health,
        attacker // We can print 'attacker' because MeleeFighter requires Debug
    )
}

fn arrow<T: RangedCombat>(attacker: &T, enemy: &mut UrukHai, distance: u32) {
    if distance < 50 {
        enemy.health -= 20;
        println!(
            "Arrow flies! Uruk-Hai health: {}. Hero status: {:?}",
            enemy.health, attacker
        );
    } else {
        println!("The Uruk-Hai is out of range!");
    }
}

fn main() {
    let gandalf = Wizard {
        name: String::from("Gandalf"),
        health: 100,
    };

    let aragon = Ranger {
        name: String::from("Aragon"),
        health: 69,
    };

    let mut lurtz = UrukHai { health: 120 };

    println!("--- The battle begins ---");
    strike_with_staff(&gandalf, &mut lurtz);
    arrow(&aragon, &mut lurtz, 20);
}
// Prints
// --- The battle begins ---
// Staff strike! Uruk-Hai Health: 105. Hero status Wizard { name: "Gandalf", health: 100 }
// Arrow flies! Uruk-Hai health: 85. Hero status: Ranger { name: "Aragon", health: 69 }

```

## The From trait

- the `From` trait is very common in Rust. We already know it can turn a `&str` into a `String`. But the standard library uses it everywhere. For example, the `Vec` type implements `From` for over 18 different types
- here is how `Vec::from()` behaves differently depending on what you feed it

```rust
fn main() {
    // From an array: Stays as numbers -> [8, 9, 10]
    let array_vec = Vec::from([8, 9, 10]);

    // From a string: Rust converts this into raw bytes (Vec<u8>)
    // Prints: [77, 111, 114, 100, 111, 114]
    let string_vec = Vec::from("Mordor");
}
```
- why does *Mordor* turn into bytes? Because characters are tricky! A single letter or emoticon (like a 🧙‍♂️ emoji or an Elvish rune) can actually take up to four bytes of memory. To keep things safe and predictable, Rust's creators decided the default conversion should break strings down into their absolute raw materials: bytes (`u8`)
- let's use our _Lord of the Rings_ theme to turn a `Vec<Rider>` into a massive `Army`

```rust
#[derive(Debug)]
struct Rider {
    name: String,
}

#[derive(Debug)]
struct Army {
    forces: Vec<Rider>,
}
// We implement From to convert a Vec of Riders into a full Army
impl From<Vec<Rider>> for Army {
    fn from(forces: Vec<Rider>) -> Self {
        Self { forces } // We pack the vector inside the Army struct
    }
}

fn main() {
    let eomer = Rider {
        name: String::from("Eomer"),
    };
    let erkenbrand = Rider {
        name: String::from("Erkenbrand"),
    };

    let rohirrim_vec = vec![eomer, erkenbrand];
    // THE CONVERSION: We pass the Vec in, and get an Army out!
    let rohan_army = Army::from(rohirrim_vec);
    println!("The army arrives: {:?}", rohan_army);
}
// Prints
// The army arrives: Army { forces: [Rider { name: "Eomer" }, Rider { name: "Erkenbrand" }] }
```
- **seeing this, you might be tempted to start implementing `From` on other types you know in the standard library. But Rust won’t always let you! Let’s find out why.**

## The orphan rule

- the **Orphan Rule** exists to prevent pure chaos. It states: you can implement our trait on a foreign type, or a foreign trait on our type, but you **cannot** implement a foreign trait on a foreign type
- if anyone could rewrite how standard types (like `Vec` or `String`) behave, different libraries would constantly clash and break each other's code
- to legally bypass this rule, you use the **Newtype Idiom**: you simply wrap the foreign type inside a brand new tuple struct that we own, giving us full control to sign any contract you want!

## The Newtype Idiom

- think of it like putting a standard `String` inside a sealed envelope: `struct PalantirMessage(String);`
- once wrapped, it acts like a completely brand-new type. It strips away all the original traits of a `String`, meaning the compiler won't even let you compare a `PalantirMessage` to a `String` directly. To read the text inside, you have to "open" the envelope using **`.0`** (e.g., `my_message.0`)
- why do this? Because `PalantirMessage` belongs to us. The Orphan Rule vanishes! We now have absolute power to implement `Display`, `From`, or any other trait on it exactly how we want
```rust
use std::fmt;

// 1. THE NEWTYPE WRAPPER
// We wrap a standard String (foreign type) inside our own type.
struct PalantirMessage(String);

// 2. BYPASSING THE ORPHAN RULE
// Because PalantirMessage is OUR type, we are legally allowed to
// implement the standard library's Display trait on it!
impl fmt::Display for PalantirMessage {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        // We use .0 to access the actual String hidden inside the envelope
        write!(f, "🔮 A dark whisper from the stone: '{}'", self.0)
    }
}

fn main() {
    // We create the inner String, then wrap it in our Newtype
    let raw_string = String::from("Sauron sees all...");
    let message = PalantirMessage(raw_string);

    // 1. Use our custom Display implementation
    println!("{}", message);

    // 2. Open the envelope to just get the raw String back out
    println!("Extracting raw text: {}", message.0);
}
// Prints
// 🔮 A dark whisper from the stone: 'Sauron sees all...'
// Extracting raw text: Sauron sees all...

```

## Accepting Both `String` and `&str`

- sometimes we want a function to read text, and we don't care if that text is an owned `String` or a `&str` 
- we can use the **`AsRef<str>`** trait bound. It tells the compiler: *"I will accept any type, as long as it can do a cheap, instant conversion into a `&str` reference."* 
```rust
// The Trait Bound: <T: AsRef<str>>
// This accepts BOTH String and &str!
fn read_elvish<T: AsRef<str>>(text: T) {
    // We must call .as_ref() to actually turn T into the &str
    let spoken_word = text.as_ref();
    println!("Gandalf reads aloud: '{}'", spoken_word);
}

fn main() {
    let spoken_rumor: &str = "Mellon";
    let ancient_tome: String = String::from("Ash nazg durbatulûk");

    // Both work perfectly!
    read_elvish(spoken_rumor);
    read_elvish(ancient_tome);

    // ❌ read_elvish(7); // Fails! An integer cannot be referenced as a string.
}
// Prints
// Gandalf reads aloud: 'Mellon'
// Gandalf reads aloud: 'Ash nazg durbatulûk'
```

- so as we can see, traits are the absolute backbone of Rust. People coming from other languages (like me) might be tempted to look at them and say, *"Oh, this is just a Class"* or *"This is just an Interface."* But, as we've seen with trait bounds, marker traits, and the Orphan Rule, traits are uniquely Rust and don't match 100% what we are used from other languages, As I said in the first sentence of the post, "for the gopher readers, traits are the interfaces of Rust" but they are different :) 

---  
🦀 In the next post, we will learn about iterators and closures
