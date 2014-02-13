require 'spec_helper'

describe Klarna::Checkout::Order do
  describe ".initialize" do
    subject do
      described_class.new \
        id:     1,
        status: 'foo'
    end

    its(:id)     { should eq 1 }
    its(:status) { should eq 'foo' }
  end

  describe "attributes" do
    it { should have_attribute(:id) } #,                 :readonly)  }
    it { should have_attribute(:merchant_reference) } #, :optional)  }
    it { should have_attribute(:purchase_country) } #,   :mandatory) }
    it { should have_attribute(:purchase_currency) } #,  :mandatory) }
    it { should have_attribute(:locale) } #,             :mandatory) }
    it { should have_attribute(:status) } #,             :readonly)  }
    it { should have_attribute(:reference) } #,          :readonly)  }
    it { should have_attribute(:reservation) } #,        :readonly)  }
    it { should have_attribute(:started_at) } #,         :readonly)  }
    it { should have_attribute(:completed_at) } #,       :readonly)  }
    it { should have_attribute(:created_at) } #,         :readonly)  }
    it { should have_attribute(:last_modified_at) } #,   :readonly)  }
    it { should have_attribute(:expires_at) } #,         :readonly)  }
  end

  describe "relations" do
    it { should have_one(:billing_address,  as: Klarna::Checkout::Address) }
    it { should have_one(:shipping_address, as: Klarna::Checkout::Address) }
    it { should have_one(:cart,             as: Klarna::Checkout::Cart) }
    it { should have_one(:customer,         as: Klarna::Checkout::Customer) }
    it { should have_one(:merchant,         as: Klarna::Checkout::Merchant) }
    it { should have_one(:gui,              as: Klarna::Checkout::Gui) }
  end

  describe "#as_json" do
    let(:order) do
      described_class.new \
        merchant_reference: 'foo',
        purchase_country:   'NO',
        purchase_currency:  'NOK',
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
          id: '666666',
          terms_uri:        'http://www.example.com/terms',
          checkout_uri:     'http://www.example.com/checkout',
          confirmation_uri: 'http://www.example.com/confirmation_uri',
          push_uri:         'http://www.example.com/push'
        }
    end

    let(:json_hash) { order.as_json }
    subject do
      json_hash
    end

    its([:merchant_reference]) { should eq 'foo' }
    its([:purchase_country])   { should eq 'NO' }
    its([:purchase_currency])  { should eq 'NOK' }
    its([:locale])             { should eq 'nb-no' }

    describe "cart/items/0" do
      subject { json_hash[:cart][:items][0] }

      its([:reference])  { should eq '1123581220325' }
      its([:name])       { should eq 'Widget' }
      its([:quantity])   { should eq 1 }
      its([:unit_price]) { should eq 666 }
      its([:tax_rate])   { should eq 2500 }
    end

    describe "merchant" do
      subject { json_hash[:merchant] }

      its([:id])               { should eq '666666' }
      its([:terms_uri])        { should eq 'http://www.example.com/terms' }
      its([:checkout_uri])     { should eq 'http://www.example.com/checkout' }
      its([:confirmation_uri]) { should eq 'http://www.example.com/confirmation_uri' }
      its([:push_uri])         { should eq 'http://www.example.com/push' }
    end
  end

  describe "#to_json" do
    it "bases it output on #as_json" do
      subject.stub(:as_json) { { foo: "bar" } }
      subject.to_json.should eq JSON.generate({ foo: "bar" })

      subject.stub(:as_json) { { bar: "foo" } }
      subject.to_json.should eq JSON.generate({ bar: "foo" })
    end
  end

  describe ".defaults" do
    context "with some defaults set" do
      before(:each) do
        described_class.defaults = {
          purchase_country:   'NO',
          purchase_currency:  'NOK',
          merchant: {
            id: '666666'
          }
        }
      end
      after(:each) do
        described_class.defaults = nil
      end

      it "all new orders have the default values" do
        order = described_class.new
        order.purchase_country.should eq  'NO'
        order.purchase_currency.should eq 'NOK'
      end

      it "should be possible to override the default values" do
        order = described_class.new(purchase_currency: 'SEK')
        order.purchase_currency.should eq 'SEK'
      end

      it "should be possible to provide any nested values without affecting the defaults" do
        order = described_class.new({
          merchant: {
            terms_uri: 'http://www.example.com/terms'
          }
        })
        order.merchant.id.should eq '666666'
        order.merchant.terms_uri.should eq 'http://www.example.com/terms'
      end

      context "when I override an already specified default value" do
        before(:each) do
          described_class.defaults = {
            purchase_currency: 'SEK'
          }
        end

        it "newly created objects should use the new default value" do
          order = described_class.new
          order.purchase_currency.should eq 'SEK'
        end

        it "shouldn't remove the old default values" do
          order = described_class.new
          order.purchase_country.should eq  'NO'
          order.merchant.id.should eq '666666'
        end
      end
    end

    it "doesn't allow setting something other than a hash" do
      expect {
        described_class.defaults = :foobar  
      }.to raise_error(ArgumentError)
    end
  end

  context "when Klarna::Checkout has been configured with some default values" do
    before(:each) do
      Klarna::Checkout.configure do |config|
        config.merchant_id = '424242'
        config.default_country  = 'NO'
        config.default_currency = 'NOK'
      end
    end

    after(:each) do
      Klarna::Checkout.reset_configuration!
    end

    it "should use the configuration's default values" do
      order = described_class.new
      order.purchase_country.should  eq 'NO'
      order.purchase_currency.should eq 'NOK'
      order.merchant.id.should       eq '424242'
    end

    context "if I specify another default merchant ID" do
      before(:each) do
        described_class.defaults = {
          purchase_country:  'SE',
          purchase_currency: 'SEK',
          merchant: {
            id: '666666'
          }
        }
      end

      it "should use my default values instead" do
        order = described_class.new
        order.purchase_country.should  eq 'SE'
        order.purchase_currency.should eq 'SEK'
        order.merchant.id.should       eq '666666'
      end
    end
  end 
end
