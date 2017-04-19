require 'bundler/setup'
require 'pry'

GEM_ROOT = File.expand_path('../..', __FILE__).freeze
require 'pattern_matching'

module ParserHelper
  def parse(source)
    Parser::CurrentRuby.parse(source)
  end

  def unparse(ast)
    PatternMatching::RewriteContainer['unparse'].call(ast)
  end

  def s(type, *children)
    Parser::AST::Node.new(type, children)
  end

  def parse_args(args_source)
    _, args, _ = *parse("def m(#{args_source}); end")
    args
  end

  def parse_guard(guard_source)
    locals = guard_source.scan(/[a-z]+/)
    source_with_locals = locals.map { |local| "#{local} = nil;" }.join(' ') + guard_source
    *local_assigns, guard = *parse(source_with_locals)
    guard
  end
end

RSpec.configure do |c|
  c.include ParserHelper
end
