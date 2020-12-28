# Pascal interpreter implemented in Ruby 3.0.0

Following [Ruslan's Blog](https://ruslanspivak.com/lsbasi-part9/).

This uses Ruby 3.0.0, to install it, use [ruby-build](https://github.com/rbenv/ruby-build).

The interpreter consumes input from `stdin` at the time of writing,
unless you specify a file name in the invocation of the script.

This implementation will not be complete, as it is following each part of the
aforementioned blog above. Each part will be completed on a different
branch. View all the branches [here](https://github.com/ascopes/lbasi/tree/trunk).

This part provides a basic compound-statement block scope, and global variable storage.

You can also assign variables to other variables to copy the value.

The program will dump all variables in the global scope table to the terminal once execution
completes.

```pas
{- scripts/HelloWorld.pas -}
begin
    x := 1;
    y := 2;
    z2 := (x*2 + y*2)
end.
```

```bash
$ ./pascal.rb scripts/HelloWorld.pas
{"X"=>1, "Y"=>2, "Z2"=>6}
```

## Performance

This implementation is not built for performance. The lexer is implemented
to read files incrementally where possible (this does not work correctly with
stdin, so using that will result in the entire script being loaded eagerly).

As of part 9, a crude benchmark can be seen with the following results:

```bash
$ # VM
$ time ruby pascal.rb <<< "
begin
    x := 1;
    y := 2;
    z2 := (x*2 + y*2);
end.
"
```
```
{"X"=>1, "Y"=>2, "Z2"=>6}
ruby pascal.rb <<<   0.14s user 0.02s system 96% cpu 0.163 total
```

```bash
$ # MJIT (including compilation time)
$ time ruby --jit pascal.rb <<< "
begin
    x := 1;
    y := 2;
    z2 := (x*2 + y*2);
end.
"
```
```
{"X"=>1, "Y"=>2, "Z2"=>6}
ruby --jit pascal.rb <<<   0.71s user 0.07s system 162% cpu 0.482 total
```
