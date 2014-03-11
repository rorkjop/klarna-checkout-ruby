module HasMany
  def has_many(association, klass = nil)
    attr_accessor association

    define_method "#{association}=" do |new_value|
      new_value = Array(new_value)
      inst_var = "@#{association}"

      if new_value.empty?
        instance_variable_set(inst_var, [])
        return
      end

      case new_value.first
      when klass
        instance_variable_set(inst_var, new_value)
      when Hash
        new_value = new_value.map { |hash| klass.new(hash) }
        instance_variable_set(inst_var, new_value)
      else
        raise "Unsupported type for relation #{association}: #{new_value.first.class.to_s}"
      end
    end
  end
end
