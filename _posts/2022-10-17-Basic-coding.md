---
layout: post
tags: [programming]
excerpt_separator: "\n\n"
---

A mini document that I had made to quickly explain the basics of programming.

> translated quickly and dirty with Google translate

## What's the point ?

> Programming automates a task that a computer/machine can perform. To do this it is necessary to translate an algorithm into a language that the computer can understand (binary).

## The variables

### Variable types

Here is a short example of a program in pseudo-code (fictional language):

```cs
print("What's your name?"); // displays What is your name?
string name = input(); // read what the user writes
print(name); // displays its name


print("How old are you?");
int age = input();
print(age);
```

In this pseudo-code I used 2 different types of variable:

- `int`: Integer: Number

- `string`: Character string

There are mainly 5 of them:

| Type | Name | Example |
|:-------- | --------------------: | ----------------: |
| `char` | Character | 'it' |
| `bool` | Boolean | true |
| `int` | Integer | 35 |
| `float` | Floating number | 3.14 |
| `string` | Character string | "Bonjour Monde !" |

### Declare a variable

Declaring a variable allows you to say _OK! I'm going to need this variable, I'm not putting a value in it at the moment but I'm going to need it._

To declare a variable in `pseudo-code`:

`type` `name`;

example:

```cs
string city;
```
- declare `city` as a variable of type `string`

### Assign variable

Assigning a variable means, assigning it a value.

Assignment is done using the `=` sign.

example:

```cs
string city;
city = "Brussels";
```

To declare __AND__ to affect a variable at once it is necessary

`type` `name` = `value`;

For example

```cs
string city = "Brussels";
```

## Functions

A function makes it possible to associate a piece of code with a name, which can make it possible to reuse it without being redundant.

example:

```cs
int requestAge() {
     print("How old are you?");
     int age = input();
     return age;
}
```

- In this example the name of the function is `requestAge`, it could have been called `request_age` also (or whatever name you prefer).

It is possible to give arguments to a function.

Here is an example:

```cs
int readNumber(phrase) {
     print(sentence)
     int number = input()
     return number;
}

int main() {
     int age = readNumber("What is your name?");
     int zip_code = readNumber("What is your zip code?");
}
```

- The `readNumber` function displays a sentence to the user and then reads a number, returns the number to the calling function (here `main` calls `readNumber`), which allows it to be reused for two similar but different uses. And saves a few redundant lines of code.

## The scope of variables

The `scope` of a variable or in other words `lifetime` defines the place in the code where you can use the variable.

example

```cs
int main() {
     int x = 5;
     {
         int y = 4;
     }
     x=2;
}
```

- this example is valid, `x` is contained between the 2 larger braces, as for `y` in the 2 smaller braces.

bad example:

```cs
int main() {
     int x = 5;
     {
         int y = 4;
     }
     x=2;
     y=2; // won't work
}
```

- here, we try to use `y` while the variable is not defined in this `scope`.

- `//` are comments, the code that follows `//` does not count, it makes it possible to comment code and understand it more easily later.
