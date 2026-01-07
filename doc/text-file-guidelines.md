# Text-File Guidelines

## Encoding and Line Breaks

The standard encoding for text files of any kind is UTF-8.

Standard line breaks are Unix-style line breaks (ASCII 10, LF, `\n`).

When reading text files, the software should also recognize Windows-style line breaks (ASCII 13 and 10, CR
and LF, `\r\n`), and possibly discard the CR.

## Line Wrapping

The standard width for text files is 110, including line breaks, so the effective standard width is 109.

Text lines should generally not exceed the width of 109. If they do, they should be wrapped. Wrapping may
be omitted if it is either not feasible, as in Markdown table cells, or if wrapping would make the file less
readable. For instance, lengthy formatted messages are usually built and output in a single line of code
without wrapping.

Where block indenting occurs in a text file, the standard indent is 2 spaces. This is also true for Rust
code, which by default uses an indent of 4 spaces.

If a line of code is wrapped, the wrapped lines should use a *hanging indent* of 4 spaces. If this cannot be
achieved because a formatting tool---e.g. Rustfmt---does not support it, the best-looking alternative
offered by the formatter may be used.

## Tabs

Tabs are *never* in use unless they are explicitly required, as in Makefiles, for example.

The standard tab width is 8.

## Titles

For section titles in documents (like this very one), *title case* should be used.

When in doubt, use the [Title Case Converter](https://titlecaseconverter.com) with the "Chicago" option.

For section titles in code, title case is not in use.

## Styling with Markdown

Wherever feasible, use Markdown. Resort to HTML only if what you want cannot be accomplished using markdown.

In general, anything "code-ish" may be enclosed in backticks (<code>`</code>). This includes file names,
pieces of code, names and values of environment variables, or command-line tools. To some extent, where they
don't impose too much noise, these backticks may even surface on the user interface:

```bash
echo Loading file \`$file\` ...
echo error: Invalid option \`-$opt\` > /dev/stderr
```

Some basic Markdown features:

| What           | Type                            | Result
| :------------- | :------------------------------ | :-----
| en dash        | `--`                            | --
| em dash        | `---`                           | ---
| code           | <code>&grave;text&grave;</code> | `text`
| italics        | `*text*`                        | *text*
| bold           | `**text**`                      | **text**
| strike-through | `~~text~~`                      | ~~text~~

Markdown isn't standardized, so not every feature will work in every environment. Rustdoc, Doxygen, Visual
Studio Code, and GitHub---only to name a few---all use their individual Markdown parsers and renderers.

A full documentation for CommonMark (used by Rustdoc) can be found
[here](https://spec.commonmark.org/0.31.2).

### Styling in Comments

Some markdown features such as `*...*` and <code>&grave;...&grave;</code> may be used in comments:

```rust
frobinate(x); // Do some *really* sophisticated stuff with `x`
```

However, literals and links should not be styled in comments for better readability:

```rust
s.pop(); // Strip trailing '\n'
assert_eq!(mem::size_of::<i32>(), 4); // See https://turbo.fish
```
