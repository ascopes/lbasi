# Pascal interpreter implemented in Ruby 3.0.0

Following [Ruslan's Blog](https://ruslanspivak.com/lsbasi-part11/).

This uses Ruby 3.0.0, to install it, use [ruby-build](https://github.com/rbenv/ruby-build).

The interpreter consumes input from `stdin` at the time of writing,
unless you specify a file name in the invocation of the script.

This implementation will not be complete, as it is following each part of the
aforementioned blog above. Each part will be completed on a different
branch. View all the branches [here](https://github.com/ascopes/lbasi/tree/trunk).

You can write basic programs in this. Conditional statements and loops and functions are not
yet supported, and the only supported types for variable declarations are `REAL` and
`INTEGER`. Once a variable is defined, it is no longer type checked afterwards however. The
types are currently just an unused type-hint.

```pascal
{ Both new style comments ... }
(* ...and old style comments -- are fully supported. *)
```

## Example

```pascal
PROGRAM test;
VAR
    a, b, c, d : INTEGER ;
    sum        : INTEGER;
    average    : REAL ;
BEGIN
    { Values to average: }
    a := 1;
    b := 3;
    c := 5;
    d := 9;

    { Sum the values: }
    sum := a + b + c + d;

    { Take the average: }
    average := sum / 4;

    (* This is an old-style Pascal comment, but we should support this too. *)
END.
```
```bash
$ time ./pascal.rb scripts/Average.pas
Resultant variables for program TEST
{"A"=>1, "B"=>3, "C"=>5, "D"=>9, "SUM"=>18, "AVERAGE"=>4.5}
./pascal.rb scripts/Average.pas  0.16s user 0.01s system 97% cpu 0.175 total
```
