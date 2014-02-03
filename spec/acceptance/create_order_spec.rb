require 'spec_helper'

describe "creating/reading order" do
  around(:each) do |example|
    VCR.use_cassette('create_order_spec') do
      example.run
    end
  end

  let(:client) do
    Klarna::Checkout::Client.new \
      shared_secret: 'foobar'
  end

  context "when I have created an order" do
    let(:order) do
      Klarna::Checkout::Order.new \
        purchase_country: 'NO',
        purchase_currency: 'NOK',
        locale: 'nb-no',
        cart: Klarna::Checkout::Cart.new({
          items: [{
            reference:  '1123581220325',
            name:       'Widget',
            quantity:   1,
            unit_price: 666,
            tax_rate:   2500
          }]
        }),
        merchant: Klarna::Checkout::Merchant.new({
          id: '1337',
          terms_uri:        'http://www.example.com/terms',
          checkout_uri:     'http://www.example.com/checkout',
          confirmation_uri: 'http://www.example.com/confirmation_uri',
          push_uri:         'http://www.example.com/push'
        })
    end

    before(:each) do
      client.create_order(order)
    end

    describe "I should be able to fetch this order and read some attributes" do
      let(:read_order) { client.read_order(order.id) }
      subject { read_order }

      it { should_not be_nil }

      its(:id)     { should eq order.id }
      its(:status) { should eq 'checkout_incomplete' }

      describe "cart" do
        subject { read_order.cart }

        its(:total_price_including_tax) { should eq 666 }
      end
    end
  end
end
