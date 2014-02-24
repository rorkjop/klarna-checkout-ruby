require "klarna/checkout/version"
require "klarna/checkout/client"
require "klarna/checkout/configuration"

require "klarna/checkout/resource"

require "klarna/checkout/address"
require "klarna/checkout/cart"
require "klarna/checkout/customer"
require "klarna/checkout/gui"
require "klarna/checkout/merchant"
require "klarna/checkout/merchant_reference"
require "klarna/checkout/order"

module Klarna
  module Checkout
    extend Klarna::Checkout::Configuration
  end
end
