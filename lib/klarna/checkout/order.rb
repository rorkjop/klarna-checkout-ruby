require 'json'

module Klarna
  module Checkout
    class Order < Resource
      attr_accessor :id, :status, :reference, :reservation, :started_at,
                    :completed_at, :created_at, :last_modified_at, :expires_at,
                    :locale

      attr_accessor :merchant_reference, :purchase_country, :purchase_currency

      has_one :billing_address,  Klarna::Checkout::Address
      has_one :shipping_address, Klarna::Checkout::Address
      has_one :cart,             Klarna::Checkout::Cart
      has_one :customer,         Klarna::Checkout::Customer
      has_one :merchant,         Klarna::Checkout::Merchant
      has_one :gui,              Klarna::Checkout::Gui

      def as_json
        json_sanitize({
          :merchant_reference => @merchant_reference,
          :purchase_country   => @purchase_country,
          :purchase_currency  => @purchase_currency,
          :locale             => @locale,
          :cart     => @cart.as_json,
          :merchant => @merchant.as_json 
        })
      end
    end
  end
end
