require 'json'
require 'klarna/checkout/concerns/has_one'
require 'klarna/checkout/concerns/has_many'

module Klarna
  module Checkout
    class Resource
      extend HasOne
      extend HasMany

      def initialize(args = {})
        args.each_pair do |attr, value|
          setter = "#{attr.to_s}="
          self.send(setter, value) if respond_to?(setter)
        end
      end

      def to_json
        sanitized_json = self.as_json.reject { |k, v| v.nil? }
        JSON.generate(sanitized_json)
      end
    end
  end
end
