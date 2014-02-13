require 'spec_helper'
require 'json'

describe Klarna::Checkout do
  describe ".configure" do
    context "after I have configured the module" do
      Klarna::Checkout.configure do |config|
        config.shared_secret = 'mysecret'
        config.merchant_id   = '1337'
      end
    end

    its(:shared_secret) { should eq 'mysecret' }
    its(:merchant_id)   { should eq '1337' }
  end
end
