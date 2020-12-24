# lbasi #2

Building a simple interpreter in Ruby, following [Ruslan's Blog](https://ruslanspivak.com/lsbasi-part2/).

This interpreter can parse basic arithmentic expressions (+, -, *, /), but ignores operator precedence.

All operations are treated as integer division. No floating point values are recognised.

Usage:

```bash
ruby lbasi.rb <<< "11 - 7 + 2 / 3"
```
