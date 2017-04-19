module List
  extend self

  def map(list, _) where list == []
    []
  end

  def map(list, handler)
    head, *tail = *list
    [handler.call(head)] + map(tail, handler)
  end
end

plus_one = proc { |n| n + 1 }
list = [1, 2, 3]
p "List.map: "
p List.map(list, plus_one)
