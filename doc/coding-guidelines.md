# Coding Guidelines

The general text-file rules from [Text-File Guidelines](text-file-guidelines.md) apply.

In this document you will find a loose collection of general, language-independent style recommendations.

## Styling in Comments

Some markdown features such as `*...*` and <code>&grave;...&grave;</code> may be used in comments:

```rust
frobinate(x); // Do some *really* sophisticated stuff with `x`
```

However, literals and links should not be styled in comments for better readability:

```rust
s.pop(); // Strip trailing '\n'
assert_eq!(mem::size_of::<i32>(), 4); // See https://turbo.fish
```

## Hexdecimal Numbers

Hexadecimal numbers are set in capital letters:

```c++
int n = 0xFF;
auto c = U'\U20AC'; // U+20AC (EURO SIGN)
