# C++ Guidelines

This document is "work in progress" and far from complete.

The general text-file rules from [Text-File Guidelines](text_file_guidelines.md) apply.

## Source-File Sections

A C++ source file may be divided into sections so that a reader can better understand its structure.

For example, if you define a struct `MyStruct`, you can place it in a section of its own:

```c++
// `MyStruct` -----------------------------------------------------------------------------------------------

struct MyStruct {
  // ...
};
```

A collection of functions may be placed in a section called "Functions":

```c++
// Functions ------------------------------------------------------------------------------------------------

void first_function() { /* ... */ }

void second_function() { /* ... */ }
```

Section headings may appear at different levels. Do not use title case:

```c++
// A first-level section ------------------------------------------------------------------------------------
// A second-level section ...................................................................................
// A third-level section  . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 
```

## Doc Comments

For doc comments, [Doxygen](https://www.doxygen.nl) is in use.

Use the at sign (`@`) for Doxygen commands. This allows for easier scanning of C++ code.

For each documented item, start with a short but descriptive sentence in a paragraph of its own:

```c++
/**
 * Processes @p x in a state-of-the-art fashion.
 * 
 * There is even more to say about this function. This happens starting a new paragraph.
 *
 * @tparam T the value type
 * @param x the value to frobnicate
 */
template<typename T>
void
frobnicate(T x) {
  Frobnicator::of(x).run();
}
```

### References

Even though Doxygen has some auto-linking, you should not rely on it. Whenever you refer to a code item, use
the `#` operator. This will raise an error if the reference cannot be resolved. For functions, the `()` can
be omitted if they are not overloaded:

```c++
/**
 * Calls #b.
 */
void a() { b(); }

/**
 * Called by #a.
 */
void b() {}
```

### Documentation Sections

Common sections in doc comments include, in this order:

- `## Examples`

Headings should start with `##`, `###`, etc. A top-level heading with a single `#` only would appear too bold
in the documentation.

### Known Issues with Doxygen

Straight single quotes in backticks, such as <code>&grave;'x'&grave;</code>, don't work. Instead, you have to
write `<code>'x'</code>`.
