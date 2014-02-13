require 'spec_helper'
require 'json'

describe Klarna::Checkout do
  describe ".configure" do
    context "without configuration" do
      describe "accessing the variables shouldn't blow up" do
        specify do
          expect { Klarna::Checkout.shared_secret }.to_not raise_error
        end

        specify do
          expect { Klarna::Checkout.merchant_id }.to_not raise_error
        end

        specify do
          expect { Klarna::Checkout.default_country }.to_not raise_error
        end

        specify do
          expect { Klarna::Checkout.default_currency }.to_not raise_error
        end
      end
    end

    context "after I have configured the module" do
      before(:each) do
        Klarna::Checkout.configure do |config|
          config.shared_secret    = 'mysecret'
          config.merchant_id      = '1337'
          config.default_country  = 'NO'
          config.default_currency = 'NOK'
        end
      end

      its(:shared_secret)    { should eq 'mysecret' }
      its(:merchant_id)      { should eq '1337' }
      its(:default_country)  { should eq 'NO' }
      its(:default_currency) { should eq 'NOK' }

      context "after resetting the configuration" do
        before(:each) do
          Klarna::Checkout.reset_configuration!
        end

        its(:shared_secret)    { should eq nil }
        its(:merchant_id)      { should eq nil }   
        its(:default_country)  { should eq nil }
        its(:default_currency) { should eq nil }     
      end
    end
  end
end
