module List
  extend self

  def flatten(list) where list == []
    []
  end

  def flatten(value) where !value.is_a?(Array)
    [value]
  end

  def flatten(list) where list != []
    head, *tail = list
    flatten(head) + flatten(tail)
  end
end

list = [ [1], 2, [[3, [4, [5]]]]]
p "List.flatten: "
p List.flatten(list)
