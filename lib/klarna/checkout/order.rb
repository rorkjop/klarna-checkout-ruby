require 'json'

module Klarna
  module Checkout
    class Order < Resource
      attr_accessor :id, :status, :reference, :reservation, :started_at,
                    :completed_at, :created_at, :last_modified_at, :expires_at,
                    :locale

      attr_accessor :merchant_reference, :purchase_country, :purchase_currency,
                    :billing_address, :shipping_address, :cart, :customer,
                    :merchant, :gui

      def cart=(new_cart)
        case new_cart
        when Klarna::Checkout::Cart
          @cart = new_cart
        when Hash
          @cart = Klarna::Checkout::Cart.new(new_cart)
        else
          raise "Unsupported type for relation Order#cart: #{new_cart.class.to_s}"
        end
      end

      def as_json
        {
          :merchant_reference => @merchant_reference,
          :purchase_country   => @purchase_country,
          :purchase_currency  => @purchase_currency,
          :locale             => @locale,
          :cart     => @cart.as_json,
          :merchant => @merchant.as_json 
        }.reject do |k, v|
          v.nil?
        end
      end
    end
  end
end
