# Pascal interpreter implemented in Ruby 3.0.0

Following [Ruslan's Blog](https://ruslanspivak.com/lsbasi-part7/).

This uses Ruby 3.0.0, to install it, use [ruby-build](https://github.com/rbenv/ruby-build).

Run the script with `./pascal-rb.rb <<< "1+1"`

The interpreter consumes input from `stdin` at the time of writing,
unless you specify a file name in the invocation of the script.

This implementation will not be complete, as it is following each part of the
aforementioned blog above. Each part will be completed on a different
branch. View all the branches [here](https://github.com/ascopes/lbasi/tree/trunk).
