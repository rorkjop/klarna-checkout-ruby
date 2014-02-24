require 'spec_helper'

describe Klarna::Checkout::Cart do
  describe "attributes" do
    it { should have_attribute(:total_price_including_tax) }
    it { should have_attribute(:total_price_excluding_tax) }
    it { should have_attribute(:total_tax_amount) }
  end

  describe "relations" do
    it { should have_many(:items,  as: Klarna::Checkout::CartItem) }
  end

  describe "#as_json" do
    let(:cart) do
      described_class.new \
        total_price_including_tax: 250,
        total_price_excluding_tax: 200,
        total_tax_amount: 50,
        items: [{
          type: 'physical',
          ean: '1123581220325',
          reference: '1123581220325',
          name: 'Widget',
          uri: 'http://www.example.com/product-uri',
          image_uri: 'http://www.example.com/product-image-uri',
          quantity: 1,
          unit_price: 250,
          total_price_excluding_tax: 200,
          total_tax_amount: 50,
          total_price_including_tax: 250,
          discount_rate: 0,
          tax_rate: 2500
        }]
    end

    let(:json_hash) { cart.as_json }
    subject do
      json_hash
    end

    describe "items/0" do
      subject { json_hash[:items][0] }

      its([:type])                      { should eq 'physical' }          
      its([:ean])                       { should eq '1123581220325' }        
      its([:reference])                 { should eq '1123581220325' }              
      its([:name])                      { should eq 'Widget' }          
      its([:uri])                       { should eq 'http://www.example.com/product-uri' }        
      its([:image_uri])                 { should eq 'http://www.example.com/product-image-uri' }              
      its([:quantity])                  { should eq 1 }              
      its([:unit_price])                { should eq 250 }                
      its([:discount_rate])             { should eq 0 }
      its([:tax_rate])                  { should eq 2500 }
    end
  end
end
