require 'spec_helper'

describe PatternMatching::Steps::Converter do
  let(:input) do
    s(:method_implementation, :m,
      s(:arity_check, 0,
        s(:guard_condition, parse_args(''),         parse('$a == 1'),       parse(':m0')),
        s(:guard_condition, parse_args(''),         parse('true'),          parse(':m00'))
      ),
      s(:arity_check, 1,
        s(:guard_condition, parse_args('a'),        parse_guard('a == 1'),  parse(':m1; nil')),
        s(:guard_condition, parse_args('a, b = 1'), parse_guard('a != b'),  parse(':m3')),
        s(:guard_condition, parse_args('a, *b'),    parse_guard('b == []'), parse(':m4'))
      ),
      s(:arity_check, 2,
        s(:guard_condition, parse_args('a, b'),     parse_guard('a == b'),  parse(':m2')),
        s(:guard_condition, parse_args('a, b = 1'), parse_guard('a != b'),  parse(':m3')),
        s(:guard_condition, parse_args('a, *b'),    parse_guard('b == []'), parse(':m4'))
      ),
      s(:arity_check, Float::INFINITY,
        s(:guard_condition, parse_args('a, *b'),    parse_guard('b == []'), parse(':m4'))
      )
    )
  end

  let(:expected_output) do
    parse(<<-CODE)
      def m(*args)
        case args.size
        when 0
          case
          when (_ = args; $a == 1)
            :m0
          when (_ = args; true)
            :m00
          else
            raise PatternMatching::NoImplementation
          end
        when 1
          case
          when (a, _ = args; a == 1)
            :m1
            nil
          when (a, b = args; b ||= 1; a != b)
            :m3
          when (a, *b = args; b == [])
            :m4
          else
            raise PatternMatching::NoImplementation
          end
        when 2
          case
          when (a, b = args; a == b)
            :m2
          when (a, b = args; b ||= 1; a != b)
            :m3
          when (a, *b = args; b == [])
            :m4
          else
            raise PatternMatching::NoImplementation
          end
        when Integer
          case
          when (a, *b = args; b == [])
            :m4
          else
            raise PatternMatching::NoImplementation
          end
        else
          raise PatternMatching::NoImplementation
        end
      end
    CODE
  end

  describe '.call' do
    it 'converts method implementation with nested arity checks and guard conditions to a nested case-when' do
      expect(
        PatternMatching::Steps::Converter.call(input)
      ).to eq(expected_output)
    end
  end
end
