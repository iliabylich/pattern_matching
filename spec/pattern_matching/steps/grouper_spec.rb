require 'spec_helper'

describe PatternMatching::Steps::Grouper do
  let(:m1) do
    s(:guarded_def, :m, parse_args('a'), parse_guard('a == 1'), # def m(a) where a == 1
      parse(':m1; nil')                                         #   :m1; nil
    )                                                           # end
  end

  let(:m2) do
    s(:guarded_def, :m, parse_args('a, b'), parse_guard('a == b'), # def m(a, b) where a == b
      parse(':m2')                                                 #   :m2
    )                                                              # end
  end

  let(:m3) do
    s(:guarded_def, :m, parse_args('a, b = 1'), parse_guard('a != b'), # def m(a, b == 1) where a != b
      parse(':m3')                                                     #   :m3
    )                                                                  # end
  end

  let(:m4) do
    s(:guarded_def, :m, parse_args('a, *b'), parse_guard('b == []'), # def m(a, *b) where b == []
      parse(':m4')                                                   #   :m4
    )                                                                # end
  end

  let(:f1) do
    s(:guarded_def, :f, s(:args), s(:true), # def f1
      parse(':f1')                #   :f1
    )                             # end
  end

  let(:input) do
    s(:class, s(:const, nil, :A), nil, # class A
      s(:begin,
        m1,
        m2,
        m3,
        m4,

        f1
      )
    )
  end

  let(:expected_m_group) do
    s(:method_implementation, :m,
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

  let(:expected_f_group) do
    s(:method_implementation, :f,
      s(:arity_check, 0,
        s(:guard_condition, parse_args(''),         s(:true),               parse(':f1'))
      )
    )
  end

  describe '.call' do
    it 'merges methods with the same name to a single one' do
      expect(
        PatternMatching::Steps::Grouper.call(input)
      ).to eq(
        s(:class, s(:const, nil, :A), nil,
          s(:begin,
            expected_m_group,
            expected_f_group
          )
        )
      )
    end
  end
end
