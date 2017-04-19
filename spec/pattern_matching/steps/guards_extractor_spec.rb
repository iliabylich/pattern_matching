require 'spec_helper'

describe PatternMatching::Steps::GuardsExtractor do
  let(:source) do
    <<-CODE
      def m(a) where a == 1
        1
        2
      end

      def m(a) where a == 2
        1
      end

      def m(a, *b) where a == b.size
        b
      end

      def m
      end
    CODE
  end

  let(:input) { parse(source) }

  let(:expected_method1) do
    s(:guarded_def,
      :m,
      s(:args, s(:arg, :a)),
      s(:send, s(:lvar, :a), :==, s(:int, 1)),
      s(:begin,
        s(:int, 1),
        s(:int, 2)
      )
    )
  end

  let(:expected_method2) do
    s(:guarded_def,
      :m,
      s(:args, s(:arg, :a)),
      s(:send, s(:lvar, :a), :==, s(:int, 2)),
      s(:int, 1)
    )
  end

  let(:expected_method3) do
    s(:guarded_def,
      :m,
      s(:args, s(:arg, :a), s(:restarg, :b)),
      s(:send, s(:lvar, :a), :==, s(:send, s(:lvar, :b), :size)),
      s(:lvar, :b)
    )
  end

  let(:expected_method4) do
    s(:guarded_def,
      :m,
      s(:args),
      s(:true),
      nil
    )
  end

  describe '.call' do
    it 'extracts all guards from method bodies' do
      expect(
        PatternMatching::Steps::GuardsExtractor.call(input)
      ).to eq(
        s(:begin,
          expected_method1,
          expected_method2,
          expected_method3,
          expected_method4
        )
      )
    end
  end
end
