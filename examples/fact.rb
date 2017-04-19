module Fact
  extend self

  def fact(n) where n == 0
    1
  end

  def fact(n) where n > 120
    raise ArgumentError, "Invoked #fact with #{n} > 120."
  end

  def fact(n)
    n * fact(n - 1)
  end
end

puts Fact.fact(5)

begin
  puts Fact.fact(1_000)
rescue ArgumentError => e
  puts "Caught #{e}"
  puts e.backtrace
end
