module Klarna
  module Checkout
    module Configuration
      %w{shared_secret merchant_id default_country default_currency}.each do |var|
        define_method("#{var}=") do |attr|
          class_variable_set("@@#{var}".to_sym, attr)
        end

        define_method(var) do
          class_variable_get("@@#{var}".to_sym) rescue nil
        end
      end

      def configure
        yield(self)
      end

      def reset_configuration!
        self.shared_secret    = nil
        self.merchant_id      = nil
        self.default_country  = nil
        self.default_currency = nil
      end
    end
  end
end
