require 'json'
require 'active_model'

module Klarna
  module Checkout
    class Order < Resource
      include ActiveModel::Validations

      attr_accessor :id, :status, :reference, :reservation, :started_at,
                    :completed_at, :created_at, :last_modified_at, :expires_at,
                    :locale, :merchant_order_data

      attr_accessor :purchase_country, :purchase_currency

      has_one :merchant_reference,  Klarna::Checkout::MerchantReference
      has_one :billing_address,     Klarna::Checkout::Address
      has_one :shipping_address,    Klarna::Checkout::Address
      has_one :cart,                Klarna::Checkout::Cart
      has_one :customer,            Klarna::Checkout::Customer
      has_one :merchant,            Klarna::Checkout::Merchant
      has_one :gui,                 Klarna::Checkout::Gui

      validates_presence_of :purchase_country, :purchase_currency, :locale
      validate :merchant_validation
      validate :cart_validation

      def as_json
        json = json_sanitize({
          :merchant_reference => (@merchant_reference && @merchant_reference.as_json),
          :purchase_country   => @purchase_country,
          :purchase_currency  => @purchase_currency,
          :locale             => @locale,
          :merchant_order_data => @merchant_order_data,
          :cart     => @cart.as_json,
          :gui      => (@gui && @gui.as_json),
          :merchant => @merchant.as_json,
          :status   => status,
          :shipping_address => (@shipping_address && @shipping_address.as_json)
        })
        if id || json[:gui].nil?
          json.delete(:gui)
        end
        if id
          json.delete(:merchant)
        end
        if status != 'created'
          json.delete(:status)
        end
        json
      end

      private

      def merchant_validation
        errors.add(:merchant, :invalid) unless merchant.valid?
      end

      def cart_validation
        errors.add(:cart, :invalid) unless cart.valid?
      end

      class << self
        def defaults
          defaults = super

          defaults = {
            purchase_country:  Klarna::Checkout.default_country,
            purchase_currency: Klarna::Checkout.default_currency,
            merchant: {
              id: Klarna::Checkout.merchant_id
            }
          }.deep_merge(defaults)

          defaults
        end
      end
    end
  end
end
