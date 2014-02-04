require "klarna/checkout/cart_item"

module Klarna
  module Checkout
    class Cart < Resource
      attr_accessor :total_price_including_tax, :total_price_excluding_tax,
                    :total_tax_amount

      has_many :items, Klarna::Checkout::CartItem

      def as_json
        {
          :total_price_including_tax => @total_price_including_tax,
          :total_price_excluding_tax => @total_price_excluding_tax,
          :total_tax_amount => @total_tax_amount,
          :items => @items.map(&:as_json)
        }
      end
    end
  end
end
