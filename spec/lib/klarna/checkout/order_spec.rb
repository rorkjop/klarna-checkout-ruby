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
    it { should have_one(:merchant_reference, as: Klarna::Checkout::MerchantReference) }
    it { should have_one(:billing_address,    as: Klarna::Checkout::Address) }
    it { should have_one(:shipping_address,   as: Klarna::Checkout::Address) }
    it { should have_one(:cart,               as: Klarna::Checkout::Cart) }
    it { should have_one(:customer,           as: Klarna::Checkout::Customer) }
    it { should have_one(:merchant,           as: Klarna::Checkout::Merchant) }
    it { should have_one(:gui,                as: Klarna::Checkout::Gui) }
  end

  describe "validations" do
    subject(:valid_order) do
      described_class.new \
        merchant_reference: {
          orderid1: 'foo',
          orderid2: 'bar'
        },
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

    it { should be_valid }

    context "when status is 'checkout_incomplete'" do
      before(:each) do
        subject.status = 'checkout_incomplete'
      end

      it "is invalid without a purchase country" do
        subject.purchase_country = nil
        subject.should_not be_valid
      end

      it "is invalid without a purchase currency" do
        subject.purchase_currency = nil
        subject.should_not be_valid
      end

      it "is invalid without a locale" do
        subject.locale = nil
        subject.should_not be_valid
      end

      let(:cart_item) { subject.cart.items[0] }

      it "is invalid without a cart item reference" do
        cart_item.reference = nil
        subject.should_not be_valid
      end

      it "is invalid without a cart item name" do
        cart_item.name = nil
        subject.should_not be_valid
      end

      it "is invalid without a cart item quantity" do
        cart_item.quantity = nil
        subject.should_not be_valid
      end

      it "is invalid without a cart item unit price" do
        cart_item.unit_price = nil
        subject.should_not be_valid
      end

      it "is invalid without a cart item tax rate" do
        cart_item.tax_rate = nil
        subject.should_not be_valid
      end

      let(:merchant) { subject.merchant }

      it "is invalid without a merchant id" do
        merchant.id = nil
        subject.should_not be_valid
      end

      it "is invalid without a merchant terms_uri" do
        merchant.terms_uri = nil
        subject.should_not be_valid
      end

      it "is invalid without a merchant checkout_uri" do
        merchant.checkout_uri = nil
        subject.should_not be_valid
      end

      it "is invalid without a merchant confirmation_uri" do
        merchant.confirmation_uri = nil
        subject.should_not be_valid
      end

      it "is invalid without a merchant push_uri" do
        merchant.push_uri = nil
        subject.should_not be_valid
      end
    end

    context "when status is 'checkout_complete' or 'created'" do
      ['checkout_complete', 'created'].each do |status|
        before(:each) do
          subject.status = 'checkout_complete'
        end

      end
    end
  end

  describe "#as_json" do
    let(:order) do
      described_class.new \
        merchant_reference: {
          orderid1: 'foo',
          orderid2: 'bar'
        },
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
        gui: {
          layout: 'desktop'
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

    shared_examples_for "it's not included when order has ID" do
      context "when 'id' is set" do
        before(:each) do
          order.id = 'foobar'
        end

        it { should be_nil }
      end
    end

    describe "merchant_reference" do
      subject { json_hash[:merchant_reference] }

      its([:orderid1]) { 'foo' }
      its([:orderid2]) { 'bar' }
    end

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

      it_behaves_like "it's not included when order has ID"
    end

    describe "gui" do
      subject { json_hash[:gui] }

      its([:layout]) { should eq 'desktop' }

      it_behaves_like "it's not included when order has ID"
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
