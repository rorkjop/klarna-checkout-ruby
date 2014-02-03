module Klarna
  module Checkout
    class Cart < Resource
      attr_accessor :total_price_including_tax, :total_price_excluding_tax,
                    :total_tax_amount

      attr_accessor :items

      def as_json
        {
          :items => @items
        }
      end
    end
  end
end
