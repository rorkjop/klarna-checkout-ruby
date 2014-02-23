require 'json'

module Klarna
  module Checkout
    class MerchantReference < Resource
      attr_accessor :orderid1, :orderid2

      def as_json
        json_sanitize({
          :orderid1 => @orderid1,
          :orderid2 => @orderid2
        })
      end
    end
  end
end
