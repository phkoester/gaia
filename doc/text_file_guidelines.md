# Text-File Guidelines

## Encoding and Line Breaks

The standard encoding for text files of any kind is UTF-8.

Standard line breaks are Unix-style line breaks (ASCII 10, LF, `\n`).

When reading text files, the software should also recognize Windows-style line breaks (ASCII 13 and 10, CR
and LF, `\r\n`).

## Line Wrapping

The standard width for text files is 110, including line breaks, so the effective standard width is 109.

Text lines should generally not exceed the width of 109. If they do, they should be wrapped. Wrapping may
be omitted if it is either not feasible, as in Markdown table cells, or if wrapping would make the file less
readable. For instance, formatted messages are often built and output in a single line of code without
wrapping.

Where block indenting occurs in a text file, the standard indent is 2 spaces. This is also true for Rust
code, which by default uses an indent of 4 spaces.

If a line of code is wrapped, the wrapped lines should use a *hanging indent* of 4 spaces. If this cannot be
achieved because a formatting tool---e.g. Rustfmt---does not support it, the best-looking alternative
offered by the formatter may be used.

## Tabs

Tabs are never in use unless they are explicitly required, as in Makefiles, for example.

The standard tab width is 8.

## Titles

For section titles in documents (like this very one), *title case* should be used.

When in doubt, use the [Title Case Converter](https://titlecaseconverter.com) with the "Chicago" option.

For section titles in code, title capitalization is not in use.

## Styling with Markdown

Wherever feasible, use Markdown. This includes comments, even if no documentation is ever generated from
these comments:

```rust
frobnicate(x); // Do some *really* sophisticated stuff with `x`
```

In general, anything "code-ish" may be enclosed in backticks (<code>`</code>). This includes file names,
pieces of code, environment variables, or command-line tools. To some extent, where they don't impose too
much noise, these backticks may even surface on the user interface:

```bash
echo Loading file \`$file\` ...
echo error: Invalid option \`-$opt\`
```

Some more Markdown features:

| What           | Type       | Result
| :------------- | :--------- | :-----
| en dash        | `--`       | --
| em dash        | `---`      | ---
| italics        | `*text*`   | *text*
| bold           | `**text**` | **text**
| strike-through | `~~text~~` | ~~text~~

A full documentation for CommonMark can be found [here](https://spec.commonmark.org/0.31.2/).
