# lbasi #5

Building a simple interpreter in Ruby, following [Ruslan's Blog](https://ruslanspivak.com/lsbasi-part5/).

This interpreter can handle left-associative expressions that represent addition, subtraction, 
multiplication, division, or remainder (modulus).

```bash
$ ./lbasi.rb <<< "5 / 3 + 2"
3.666666666666667
```

It also supports nested operations by using parenthesis.

```bash
$ ./lbasi.rb <<< "5 / (3 + 2)"
1.0
```

Lastly, unary `+` and unary `-` can also be applied to expressions.

```bash
$ ./lbasi.rb <<< "5 / (3 - -1)"
1.25
$ ./lbasi.rb <<< "-(+5 / (3 - -1))"
-1.25
```

## Grammar

The current grammar is as follows (using [EBNF notation](https://en.wikipedia.org/wiki/Extended_Backus%E2%80%93Naur_form#Examples)).

```
expr = term , '+' , term
     | term , '-' , term
     | term
     ;

term = bitwise , '*' , bitwise
     | bitwise , '/' , bitwise
     | bitwise , '%' , bitwise
     | bitwise
     ;

bitwise = unary , '&' , unary
        | unary , '|' , unary
        | unary , '^' , unary
        | unary
        ;

unary = '+' , expr
      | '-' , expr
      | '~' , expr
      | factor
      ;

factor = parenthesis
       | NUMBER
       ;

parenthesis = '(' , expr , ')'
            ;

NUMBER = {DIGIT} , ['.' , {DIGIT}]
       ;

DIGIT = '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9'
      ;
```