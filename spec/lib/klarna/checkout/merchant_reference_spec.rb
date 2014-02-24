require 'spec_helper'

describe Klarna::Checkout::MerchantReference do
  describe ".initialize" do
    subject do
      described_class.new \
        orderid1: 'bar',
        orderid2: 'foo'
    end

    its(:orderid1) { should eq 'bar' }
    its(:orderid2) { should eq 'foo' }
  end

  describe "attributes" do
    it { should have_attribute(:orderid1) } #, :optional)  }
    it { should have_attribute(:orderid2) } #, :optional)  }
  end

  describe "#as_json" do
    let(:merchant_reference) do
      described_class.new \
        orderid1: 'foo',
        orderid2: 'bar'
    end

    let(:json_hash) { merchant_reference.as_json }
    subject do
      json_hash
    end

    its([:orderid1]) { should eq 'foo' }
    its([:orderid2]) { should eq 'bar' }
  end
end
