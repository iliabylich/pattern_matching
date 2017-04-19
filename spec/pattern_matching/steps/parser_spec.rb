require 'spec_helper'

describe PatternMatching::Steps::Parser do
  describe '.call' do
    it 'parses provided source code to ast' do
      expect(
        PatternMatching::Steps::Parser.call('1 + 1')
      ).to eq(
        s(:send, s(:int, 1), :+, s(:int, 1))
      )
    end
  end
end
