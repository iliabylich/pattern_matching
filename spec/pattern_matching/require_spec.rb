require 'spec_helper'

describe PatternMatching do
  describe '.require' do
    before { Object.send(:remove_const, :TestClass) rescue nil }

    it 'read provided filepath, rewrites it and evals' do
      PatternMatching.require(File.join(GEM_ROOT, 'spec/fixtures/sample.rb.pm'))

      instance = TestClass.new

      expect(instance.m(1)).to eq(:body1)

      expect(instance.m(2)).to eq(:body2)

      expect(instance.m(3)).to eq(nil)

      expect(instance.m(1, 1)).to eq(:body4)
      expect(instance.m(10, 10)).to eq(:body4)

      expect(instance.m(1, :one)).to eq(:body5)
      expect(instance.m(2, :one, :two)).to eq(:body5)

      expect { instance.m(2, :one) }.to raise_error(PatternMatching::NoImplementation)
      expect { instance.m }.to raise_error(PatternMatching::NoImplementation)

      expect(instance.f(1)).to eq(nil)
      expect(instance.f([1, :any, 'value'])).to eq(nil)
      expect { instance.f }.to raise_error(PatternMatching::NoImplementation)
      expect { instance.f(1, 2) }.to raise_error(PatternMatching::NoImplementation)

      expect(instance.g(1)).to eq(:body7)
      expect { instance.g }.to raise_error(PatternMatching::NoImplementation)
      expect { instance.g(1, 2) }.to raise_error(PatternMatching::NoImplementation)

      expect(instance.z).to eq(:body8)
      expect(instance.z(1, 2)).to eq(:body9)
      expect { instance.z(1) }.to raise_error(PatternMatching::NoImplementation)
    end
  end
end
