require 'json'

require 'klarna/hash/deep_merge'
require 'klarna/checkout/concerns/has_one'
require 'klarna/checkout/concerns/has_many'

module Klarna
  module Checkout
    class Resource
      extend HasOne
      extend HasMany

      def initialize(args = {})
        self.class.defaults.deep_merge(args).each_pair do |attr, value|
          setter = "#{attr.to_s}="
          self.send(setter, value) if respond_to?(setter)
        end
      end

      def to_json
        sanitized_json = json_sanitize(self.as_json)
        JSON.generate(sanitized_json)
      end

      def json_sanitize(hash)
        hash.reject { |k, v| v.nil? }
      end

      class << self
        def defaults=(hash)
          raise ArgumentError.new unless hash.is_a? Hash

          @defaults = hash
        end

        def defaults
          @defaults || {}
        end
      end
    end
  end
end
