class PatternMatching::Steps::GuardsExtractor < PatternMatching::Rewriter
  def on_def(node)
    method_name, args, body = *node

    if body && body.type == :begin
      # multiline body wrapped with s(:begin, ...)
      guard, *post_guard = *body
    else
      # singleline body that has only a guard
      guard, post_guard = body, nil
    end

    if guard && guard.type == :send
      receiver, mid, guard = *guard

      if receiver.nil? && mid == :where
        # method starts from "where ...", so it's really a guard

        if post_guard.is_a?(Array)
          if post_guard.length == 1
            # no need to wrap the rest with "begin; end" is it's a single line
            post_guard = post_guard.first
          else
            post_guard = s(:begin, *post_guard)
          end
        end

        return s(:guarded_def, method_name, args, guard, post_guard)
      end
    end

    # No guard = constant guard "where true"
    s(:guarded_def, method_name, args, s(:true), body)
  end
end
