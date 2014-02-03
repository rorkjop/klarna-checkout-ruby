module Klarna
  module Checkout
    class Gui < Resource
      attr_accessor :layout, :options, :snippet

      def as_json
        {
          :layout  => @layout,
          :options => @options
        }
      end
    end
  end
end
