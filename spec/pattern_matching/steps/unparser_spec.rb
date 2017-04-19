require 'spec_helper'

describe PatternMatching::Steps::Unparser do
  describe '.call' do
    it 'converts provided ast back to the source' do
      expect(
        PatternMatching::Steps::Unparser.call(parse('1 + 1'))
      ).to eq('1 + 1')
    end
  end
end
