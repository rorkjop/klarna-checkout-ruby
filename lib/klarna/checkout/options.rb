require 'active_model'

module Klarna
  module Checkout
    class Options < Resource
      attr_accessor :allow_separate_shipping_address, :color_button, :color_button_text, :color_checkbox,
                    :color_checkbox_checkmark, :color_header, :color_link, :date_of_birth_mandatory, :shipping_details

      def as_json
        json_sanitize({
          :allow_separate_shipping_address => @allow_separate_shipping_address,
          :color_button                    => @color_button,
          :color_button_text               => @color_button_text,
          :color_checkbox                  => @color_checkbox,
          :color_checkbox_checkmark        => @color_checkbox_checkmark,
          :color_header                    => @color_header,
          :color_link                      => @color_link,
          :date_of_birth_mandatory         => @date_of_birth_mandatory,
          :shipping_details                => @shipping_details,
        })
      end
    end
  end
end
