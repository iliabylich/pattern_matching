class PatternMatching::Steps::Converter < PatternMatching::Rewriter
  # raise PatternMatching::NoImplementation
  ELSE_RAISE_NODE = s(:send, nil, :raise, s(:const, s(:const, nil, :PatternMatching), :NoImplementation)).freeze

  # *args
  ARGS_NODE = s(:args, s(:restarg, :args)).freeze

  # args.size
  ARITY_SIZE_NODE = s(:send, s(:lvar, :args), :size).freeze

  def on_method_implementation(node)
    ImplementationRewriter.call(node)
  end

  class ImplementationRewriter < PatternMatching::Rewriter
    def on_method_implementation(node)
      method_name, *arity_checks = *node

      body = s(:case,
        ARITY_SIZE_NODE,
        *process_all(arity_checks),
        ELSE_RAISE_NODE
      )

      s(:def, method_name, ARGS_NODE, body)
    end

    def on_arity_check(node)
      arity, *guards = *node

      guard_case = s(:case,
        nil,
        *process_all(guards),
        ELSE_RAISE_NODE
      )

      arity_check_node = arity == Float::INFINITY ? s(:const, nil, :Integer) : s(:int, arity)

      s(:when, arity_check_node, guard_case)
    end

    def on_guard_condition(node)
      @optargs = {}
      args, guard, body = *node
      assign_args_to_locals = process(args)
      assign_optargs = @optargs.map do |name, value|
        s(:or_asgn, s(:lvasgn, name), value)
      end

      s(:when, s(:begin, assign_args_to_locals, *assign_optargs, guard), body)
    end

    def on_args(node)
      locals = process_all(node.children)

      if locals.empty?
        return s(:lvasgn, :_, s(:lvar, :args))
      end

      if locals.size == 1
        locals << s(:lvasgn, :_)
      end

      s(:masgn,
        s(:mlhs, *locals),
        s(:lvar, :args)
      )
    end

    def on_arg(node)
      name, _ = *node
      s(:lvasgn, name)
    end

    def on_optarg(node)
      name, value = *node
      @optargs[name] = value
      s(:lvasgn, name)
    end

    def on_restarg(node)
      name, _ = *node
      s(:splat, s(:lvasgn, name))
    end
  end
end
