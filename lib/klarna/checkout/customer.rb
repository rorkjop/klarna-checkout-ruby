module Klarna
  module Checkout
    class Customer < Resource
      attr_accessor :type

      def as_json
        json_sanitize({
          :type => @type
        })
      end
    end
  end
end
