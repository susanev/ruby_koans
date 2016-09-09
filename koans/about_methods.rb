require File.expand_path(File.dirname(__FILE__) + '/neo')

def my_global_method(a,b)
  a + b
end

class AboutMethods < Neo::Koan

  def test_calling_global_methods
    assert_equal 5, my_global_method(2,3)
  end

  def test_calling_global_methods_without_parentheses
    result = my_global_method 2, 3
    assert_equal 5, result
  end

  def method_with_defaults(a, b=:default_value)
    [a, b]
  end

  def test_calling_with_default_values
    assert_equal [1, :default_value], method_with_defaults(1)
    assert_equal [1, 2], method_with_defaults(1, 2)
  end

  # ------------------------------------------------------------------

  def method_with_explicit_return
    :a_non_return_value
    return :return_value
    :another_non_return_value
  end

  def test_method_with_explicit_return
    assert_equal :return_value, method_with_explicit_return
  end

  # ------------------------------------------------------------------

  def method_without_explicit_return
    :a_non_return_value
    :return_value
  end

  def test_method_without_explicit_return
    assert_equal :return_value, method_without_explicit_return
  end

  # ------------------------------------------------------------------

  def my_method_in_the_same_class(a, b)
    a * b
  end

  def test_calling_methods_in_same_class
    assert_equal 12, my_method_in_the_same_class(3,4)
  end

  def test_calling_methods_in_same_class_with_explicit_receiver
    assert_equal 12, self.my_method_in_the_same_class(3,4)
  end

end
