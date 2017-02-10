module HasOne
  def has_one(association, klass = nil)
    attr_accessor association

    define_method "#{association}=" do |new_value|
      inst_var = "@#{association}"
      case new_value
      when klass
        instance_variable_set(inst_var, new_value)
      when Hash
        instance_variable_set(inst_var, klass.new(new_value))
      else
        raise "Unsupported type for relation #{association}: #{new_value.class}"
      end
    end
  end
end
