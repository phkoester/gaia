# Coding Guidelines

The general text-file rules from [Text-File Guidelines](text-file-guidelines.md) apply.

In this document you will find a loose collection of general, language-independent style recommendations.

## Source-File Sections

A source file may be divided into sections so that a reader can better understand its structure.

For example, if you define a C++ class `MyStruct`, you can place it in a section of its own:

```c++
// `MyStruct` -----------------------------------------------------------------------------------------------

struct MyStruct {
  ...
};
```

A collection of functions may be placed in a section called "Functions":

```c++
// Functions ------------------------------------------------------------------------------------------------

void firstFunction() { ... }

void secondFunction() { ... }
```

Section headings may appear at different levels. Do not use title case:

```c++
// A first-level section ------------------------------------------------------------------------------------
// A second-level section ...................................................................................
// A third-level section  . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .
```

In some cases, where an additional "zero-level" section is needed, you may use a ruler like this:

```c++
// Part I: the general idea =================================================================================

// A first-level section ------------------------------------------------------------------------------------

// Part II: the implementation ==============================================================================

// Another first-level section ------------------------------------------------------------------------------
```

## Styling in Comments

Some Markdown features such as `*...*` and <code>&grave;...&grave;</code> may be used in comments:

```rust
frobnicate(x); // Do some *really* sophisticated stuff with `x`
```

However, literals and links should not be styled in comments for better readability:

```rust
str.pop(); // Strip trailing '\n'
assert_eq!(mem::size_of::<i32>(), 4); // See https://turbo.fish
```

## Hexadecimal Numbers

Hexadecimal numbers are set in capital letters:

```c++
i32 n = 0xFF;
auto c = U'\u20AC'; // U+20AC (EURO SIGN)
```
