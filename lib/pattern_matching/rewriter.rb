class PatternMatching::Rewriter < Parser::AST::Processor
  def s(type, *children)
    self.class.s(type, *children)
  end

  def self.call(ast)
    new.process(ast)
  end

  def self.s(type, *children)
    Parser::AST::Node.new(type, children)
  end
end
