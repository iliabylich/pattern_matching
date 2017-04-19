class PatternMatching::Steps::Grouper < PatternMatching::Rewriter
  def rewrite_body(body)
    @methods = Hash.new { |h, k| h[k] = [] }

    body = process_regular_node(body)

    non_methods = body.to_a.reject { |node| node == s(:nil) }

    grouped = @methods.map do |method_name, implementations|
      SingleGroup.new(method_name, implementations).to_ast
    end

    s(:begin, *non_methods, *grouped)
  end

  def on_class(node)
    klass, superklass, body = *node
    body = rewrite_body(body)
    node.updated(nil, [klass, superklass, body])
  end

  def on_module(node)
    mod, body = *node
    body = rewrite_body(body)
    node.updated(nil, [mod, body])
  end

  def on_guarded_def(node)
    method_name, args, guard, body = *node
    arities = ArityCalculator.new(args).range
    @methods[method_name] << { args: args, guard: guard, body: body, arities: arities }
    s(:nil)
  end

  class ArityCalculator < Struct.new(:args)
    def range
      min = max = 0

      args.children.each do |arg|
        case arg.type
        when :arg
          min += 1
          max += 1
        when :optarg
          max += 1
        when :restarg
          max = Float::INFINITY
        end
      end

      (min..max)
    end
  end

  class SingleGroup < Struct.new(:method_name, :implementations)
    def to_ast
      infinite, finite = implementations.partition { |arities:, **| arities.end == Float::INFINITY }

      result = Hash.new { |h, k| h[k] = [] }

      finite.each do |arities:, **implementation|
        arities.each do |possible_arity|
          result[possible_arity] << implementation
        end
      end

      max_fixed_arity = result.keys.max

      infinite.each do |arities:, **implementation|
        (arities.begin..max_fixed_arity).each do |possible_arity|
          result[possible_arity] << implementation
        end

        result[Float::INFINITY] << implementation
      end

      arity_implementations = result.sort_by(&:first).map do |fixed_arity, implementations|
        guard_implementations = implementations.map do |args:, guard:, body:|
          s(:guard_condition, args, guard, body)
        end

        s(:arity_check, fixed_arity, *guard_implementations)
      end

      s(:method_implementation, method_name, *arity_implementations)
    end

    private

    def s(type, *children)
      Parser::AST::Node.new(type, children)
    end
  end
end
