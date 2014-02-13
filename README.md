[![Build Status](https://magnum.travis-ci.com/Skalar/klarna-checkout-ruby.png?token=e2yW3RUEf8aqmbRkK1DS)](https://magnum.travis-ci.com/Skalar/klarna-checkout-ruby) [![Code Climate](https://codeclimate.com/github/Skalar/klarna-checkout-ruby.png)](https://codeclimate.com/github/Skalar/klarna-checkout-ruby)

# Klarna Checkout

Unofficial Ruby Wrapper for Klarnas Checkout Rest API.

## Installation

Add this line to your application's Gemfile:

    gem 'klarna-checkout'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install klarna-checkout

## Usage

```ruby
require 'klarna/checkout'

# a) Create a client with shared_secret directly
client = Klarna::Checkout::Client.new({
  shared_secret: 'your-shared-secret',
  environment: :test # or :production
})

# b) Create a client with shared_secret from module configuration
Klarna::Checkout.configure do |config|
  config.shared_secret = 'your-shared-secret'
end

client = Klarna::Checkout::Client.new(environment: :test)
client.shared_secret
# => 'your-shared-secret'


# Initialize an order
order = Klarna::Checkout::Order.new({
  purchase_country: 'NO',
  purchase_currency: 'NOK',
  locale: 'nb-no',
  cart: {
    items: [{
      reference:  '1123581220325',
      name:       'Widget',
      quantity:   1,
      unit_price: 666,
      tax_rate:   2500
    }]
  },
  merchant: {
    id: '1337',
    terms_uri:        'http://www.example.com/terms',
    checkout_uri:     'http://www.example.com/checkout',
    confirmation_uri: 'http://www.example.com/confirmation_uri',
    push_uri:         'http://www.example.com/push'
  }
})


# Create the order with Klarna
client.create_order(order)
order.id
# => ID of the order (no other attributes are updated)


# Read an order from Klarna
order = client.read_order("1234ABCD")


# Instead of repeating yourself with supplying the same attributes for each 
# order you can configure some default attributes
Klarna::Checkout::Order.defaults = {
  purchase_country: 'NO',
  purchase_currency: 'NOK',
  locale: 'nb-no',
  merchant: {
    id: '1337',
    terms_uri:        'http://www.example.com/terms',
    checkout_uri:     'http://www.example.com/checkout',
    confirmation_uri: 'http://www.example.com/confirmation_uri',
    push_uri:         'http://www.example.com/push'
  }
}

# All newly created orders will then have these attributes
order = Klarna::Checkout::Order.new
order.purchase_country
# => 'NO'
```

## TODO

* Validation of objects according to documentation
* Respect readonly attributes

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes, don't forget to add tests (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
