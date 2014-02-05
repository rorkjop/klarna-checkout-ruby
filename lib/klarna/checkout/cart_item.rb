module Klarna
  module Checkout
    class CartItem < Resource
      attr_accessor :type, :ean, :reference, :name, :uri, :image_uri, :quantity,
                    :unit_price, :total_price_excluding_tax, :total_tax_amount,
                    :total_price_including_tax, :discount_rate, :tax_rate

      def as_json
        json_sanitize({
          :type => @type,
          :ean => @ean,
          :reference => @reference,
          :name => @name,
          :uri => @uri,
          :image_uri => @image_uri,
          :quantity => @quantity,
          :unit_price => @unit_price,
          :total_price_excluding_tax => @total_price_excluding_tax,
          :total_tax_amount => @total_tax_amount,
          :total_price_including_tax => @total_price_including_tax,
          :discount_rate => @discount_rate,
          :tax_rate => @tax_rate
        })
      end
    end
  end
end
