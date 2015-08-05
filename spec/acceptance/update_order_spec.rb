require 'spec_helper'

describe "updating existing order" do
  around(:each) do |example|
    VCR.use_cassette('update_order_spec') do
      example.run
    end
  end

  let(:client) do
    Klarna::Checkout::Client.new \
      shared_secret: 'foobar'
  end

  let(:order) { client.read_order('1445FB9ACFD90B11C39E7220000') }

  describe "updating the order" do
    context "after updating the merchant_reference and cart item quantity" do
      before(:each) do
        order.merchant_reference = {
          orderid1: 'newreference'
        }
        order.cart.items[0].quantity = 50

        client.update_order(order)
      end

      describe "the order read from the api" do
        subject do
          VCR.use_cassette('update_order_spec-2') do
            client.read_order('1445FB9ACFD90B11C39E7220000')
          end
        end

        specify { expect(subject.merchant_reference.orderid1).to eq 'newreference' }
        specify { expect(subject.cart.items[0].quantity).to eq 50 }
      end
    end
  end
end
