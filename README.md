## Pattern Matching

No runtime calculations, rewriting is performed before requiring the source file.
Uses [Parser](https://github.com/whitequark/parser) and [Unparser](https://github.com/mbj/unparser)

### Installing

```
git clone https://github.com/iliabylich/pattern_matching
cd pattern_matching
bundle
```

### Examples


``` sh
$ cat examples/fact.rb
     1  module Fact
     2    extend self
     3
     4    def fact(n) where n == 0
     5      1
     6    end
     7
     8    def fact(n) where n > 120
     9      raise ArgumentError, "Invoked #fact with #{n} > 120."
    10    end
    11
    12    def fact(n)
    13      n * fact(n - 1)
    14    end
    15  end
    16
    17  puts Fact.fact(5)
    18
    19  begin
    20    puts Fact.fact(1_000)
    21  rescue ArgumentError => e
    22    puts "Caught #{e}"
    23    puts e.backtrace
    24  end

puts Fact.new.fact(5)
# => 120
puts Fact.new.fact(1_000)
# => Invoked #fact with 1000 > 120. (ArgumentError)

$ DEBUG=true ./bin/ruby.pm examples/fact.rb
[DEBUG] Running examples/fact.rb:
     1: module Fact
     2:   extend(self)
     3:   def fact(*args)
     4:     case args.size
     5:     when 1
     6:       case
     7:       when (n, _ = args
     8:       n == 0)
     9:         1
    10:       when (n, _ = args
    11:       n > 120)
    12:         raise(ArgumentError, "#{"Invoked #fact with "}#{n}#{" > 120."}")
    13:       when (n, _ = args
    14:       true)
    15:         n * fact(n - 1)
    16:       else
    17:         raise(PatternMatching::NoImplementation)
    18:       end
    19:     else
    20:       raise(PatternMatching::NoImplementation)
    21:     end
    22:   end
    23: end
    24: puts(Fact.fact(5))
    25: begin
    26:   puts(Fact.fact(1000))
    27: rescue ArgumentError => e
    28:   puts("#{"Caught "}#{e}")
    29:   puts(e.backtrace)
    30: end

120
Caught Invoked #fact with 1000 > 120.
./examples/fact.rb:12:in `fact'
./examples/fact.rb:26:in `require'
./lib/pattern_matching.rb:60:in `module_eval'
./lib/pattern_matching.rb:60:in `require'
./bin/ruby.pm:22:in `run_file'
```

Or run all examples:
``` sh
$ export DEBUG=true; find examples/*.rb | xargs ./bin/ruby.pm
```

### Running test

``` sh
$ rspec
```
