class TestClass
  def m(a) where a == 1
    :body1
  end

  def m(a) where a == 2
    :body2
  end

  def m(a)
  end

  def m(a, b) where a == b
    :body4
  end

  def m(a, *b) where b.size == a
    :body5
  end

  def f(a)
  end

  def g(a)
    :body7
  end

  def z
    :body8
  end

  def z(a, b)
    :body9
  end
end
