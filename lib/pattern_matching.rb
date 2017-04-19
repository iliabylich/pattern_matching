require 'parser/current'
require 'unparser'
require 'dry-container'
require 'dry-transaction'
require 'dry-monads'

class PatternMatching
  NoImplementation = Class.new(ArgumentError)

  autoload :Rewriter, 'pattern_matching/rewriter'

  module Steps
    autoload :Parser,          'pattern_matching/steps/parser'
    autoload :GuardsExtractor, 'pattern_matching/steps/guards_extractor'
    autoload :Grouper,         'pattern_matching/steps/grouper'
    autoload :Converter,       'pattern_matching/steps/converter'
    autoload :Unparser,        'pattern_matching/steps/unparser'
  end

  class RewriteContainer
    extend Dry::Container::Mixin

    register :parse, ->(source) {
      PatternMatching::Steps::Parser.call(source)
    }

    register :extract_guards, ->(ast) {
      PatternMatching::Steps::GuardsExtractor.call(ast)
    }

    register :group, ->(ast) {
      PatternMatching::Steps::Grouper.call(ast)
    }

    register :convert, ->(ast) {
      PatternMatching::Steps::Converter.call(ast)
    }

    register :unparse, ->(ast) {
      PatternMatching::Steps::Unparser.call(ast)
    }
  end

  REWRITE = Dry.Transaction(container: RewriteContainer) do
    map :parse
    map :extract_guards
    map :group
    map :convert
    map :unparse
  end.freeze

  class << self
    def process(source)
      REWRITE.call(source).value
    end

    def require(filepath)
      source = File.read(filepath)
      rewritten = process(source)
      Object.send(:module_eval, rewritten, filepath)
    end
  end
end
