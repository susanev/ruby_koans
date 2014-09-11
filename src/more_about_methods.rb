require File.expand_path(File.dirname(__FILE__) + '/neo')

def my_global_method(a,b)
  a + b
end

class MoreAboutMethods < Neo::Koan

  # (NOTE: We are Using eval below because the example code is
  # considered to be syntactically invalid).
  def test_sometimes_missing_parentheses_are_ambiguous
    #--
    eval "assert_equal 5, my_global_method(2, 3)" # REMOVE CHECK # __
    if false
      #++
    eval "assert_equal 5, my_global_method 2, 3" # ENABLE CHECK # __
      #--
    end
    #++
    #
    # Ruby doesn't know if you mean:
    #
    #   assert_equal(5, my_global_method(2), 3)
    # or
    #   assert_equal(5, my_global_method(2, 3))
    #
    # Rewrite the eval string to continue.
    #
  end

  # NOTE: wrong number of arguments is not a SYNTAX error, but a
  # runtime error.
  def test_calling_global_methods_with_wrong_number_of_arguments
    exception = assert_raise(___(ArgumentError)) do
      my_global_method
    end
    #--
    pattern = "wrong (number|#) of arguments"
    #++
    assert_match(/#{__(pattern)}/, exception.message)

    exception = assert_raise(___(ArgumentError)) do
      my_global_method(1,2,3)
    end
    assert_match(/#{__(pattern)}/, exception.message)
  end


  # ------------------------------------------------------------------

  def method_with_var_args(*args)
    args
  end

  def test_calling_with_variable_arguments
    assert_equal __(Array), method_with_var_args.class
    assert_equal __([]), method_with_var_args
    assert_equal __([:one]), method_with_var_args(:one)
    assert_equal __([:one, :two]), method_with_var_args(:one, :two)
  end

  # ------------------------------------------------------------------

  def my_private_method
    "a secret"
  end
  private :my_private_method

  def test_calling_private_methods_without_receiver
    assert_equal __("a secret"), my_private_method
  end

  def test_calling_private_methods_with_an_explicit_receiver
    exception = assert_raise(___(NoMethodError)) do
      self.my_private_method
    end
    assert_match /#{__("method `my_private_method'")}/, exception.message
  end

  # ------------------------------------------------------------------

  class Dog
    def name
      "Fido"
    end

    private

    def tail
      "tail"
    end
  end

  def test_calling_methods_in_other_objects_require_explicit_receiver
    rover = Dog.new
    assert_equal __("Fido"), rover.name
  end

  def test_calling_private_methods_in_other_objects
    rover = Dog.new
    assert_raise(___(NoMethodError)) do
      rover.tail
    end
  end
end
