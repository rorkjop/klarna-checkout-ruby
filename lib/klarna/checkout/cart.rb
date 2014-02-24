require 'active_model'
require 'klarna/checkout/cart_item'

module Klarna
  module Checkout
    class Cart < Resource
      include ActiveModel::Validations

      attr_accessor :total_price_including_tax, :total_price_excluding_tax,
                    :total_tax_amount

      has_many :items, Klarna::Checkout::CartItem

      validate :items_validation

      def as_json
        json_sanitize({
          :items => @items.map(&:as_json)
        })
      end

      private

      def items_validation
        errors.add(:items, :invalid) unless items.all?(&:valid?)
      end
    end
  end
end
