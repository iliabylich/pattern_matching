module PatternMatching::Steps::Parser
  module_function

  def call(source)
    Parser::CurrentRuby.parse(source)
  end
end
