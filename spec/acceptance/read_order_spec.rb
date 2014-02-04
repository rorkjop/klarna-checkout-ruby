require 'spec_helper'

describe "reading order" do
  around(:each) do |example|
    VCR.use_cassette('read_order_spec') do
      example.run
    end
  end

  let(:client) do
    Klarna::Checkout::Client.new \
      shared_secret: 'foobar'
  end

  describe "I should be able to fetch an order and read its attributes" do
    let(:read_order) { client.read_order('143F7EB92CD90B11C39E7220000') }
    subject { read_order }

    it { should_not be_nil }

    its(:id)     { should eq '143F7EB92CD90B11C39E7220000' }
    its(:status) { should eq 'checkout_incomplete' }

    describe "cart" do
      subject { read_order.cart }

      its(:total_price_including_tax) { should eq 666 }
    end
  end
end
