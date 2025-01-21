# Rust Guidelines

This document is "work in progress" and far from complete.

The general text-file rules from [Text-File Guidelines](text_file_guidelines.md) apply.

Next, you should read the [Rust API Guidelines](https://rust-lang.github.io/api-guidelines/about.html).

## Rustfmt

The `rustfmt.toml` file from the `meadows` project serves as a reference. It contains the Rustfmt settings to
be used. It makes use of unstable Rustfmt features, so the Rust nightly toolchain is required. 

### Rustfmt in Visual Studio Code

In Code, Alt+Shift+F formats the current Rust-source file.

To enable the unstable features, `settings.json` needs the following entry:

```json
  "rust-analyzer.rustfmt.extraArgs": ["+nightly"]
```

## Lints

The `Cargo.toml` file from the `meadows` project serves as a reference. It contains the lint settings to be
used by `rustc` and Clippy.

## Source-File Sections

A Rust source file may be divided into sections so that a reader can better understand its structure.

For example, if you define a struct `MyStruct`, you can place it in a section of its own:

```rust
// `MyStruct` -----------------------------------------------------------------------------------------------

struct MyStruct {
  // ...
}

impl MyStruct {
  // ...
}
```

A collection of functions may be placed in a section called "Functions":

```rust
// Functions ------------------------------------------------------------------------------------------------

fn first_function() { /* ... */ }

fn second_function() { /* ... */ }
```

Unit tests always come at the end of a source file, in a unique "Tests" section. To group the tests, the
above sections from the source may be repeated, indented by one level:

```rust
// Tests ====================================================================================================

#[cfg(test)]
mod tests {
  use super::*;

  // `MyStruct` ---------------------------------------------------------------------------------------------

  #[test]
  fn test_my_struct() { /* ... */ }

  // Functions ----------------------------------------------------------------------------------------------

  #[test]
  fn test_first_function() { /* ... */ }
  
  #[test]
  fn test_second_function() { /* ... */ }
}
```

Section headings may appear at different levels. Do not use title case:

```rust
// Tests (top-level, only for unit tests) ===================================================================
// A first-level section ------------------------------------------------------------------------------------
// A second-level section ...................................................................................
// A third-level section  . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
```

## Doc Comments

For doc comments, [Rustdoc](https://doc.rust-lang.org/rustdoc) is in use.

For each documented item, start with a short but descriptive sentence in a paragraph of its own:

```rust
/// Processes `x` in a state-of-the-art fashion.
///
/// There is even more to say about this function. This happens starting a new paragraph.
pub fn frobnicate(x: i32) {
  Frobnicator::with(x).run();
}
```

### References

References to code items should be set in a monospaced font, so use backticks in the link description:

```rust
/// The function takes a [`String`] and presumably does something with it.
pub fn take(val: String) { /* ... */ }
```

### Documentation Sections

Common sections in doc comments include, in this order:

- `# Safety`
- `# Errors`
- `# Panics`
- `# Examples`

### Known Issues with Rustfmt

Rustfmt wraps Markdown-table lines if they don't start with a `|`. To protect your Markdown tables from
Rustfmt, start each table line with a `|`.
