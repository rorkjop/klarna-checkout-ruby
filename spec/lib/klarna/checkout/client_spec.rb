require 'spec_helper'
require 'json'

describe Klarna::Checkout::Client do
  describe ".new" do
    subject do
      described_class.new({
        shared_secret: 'foobar'
      })
    end

    its(:shared_secret) { should eq 'foobar' }

    context "when Klarna::Checkout is configured with a shared_secret" do
      before(:each) do
        Klarna::Checkout.configure do |config|
          config.shared_secret = 'foobar'
        end
      end

      after(:each) do
        Klarna::Checkout.reset_configuration!
      end

      it "shouldn't be necessary to provide the secret twice" do
        expect(described_class.new.shared_secret).to eq 'foobar'
      end
    end
  end

  describe "#environment" do
    it "defaults to :test" do
      expect(subject.environment).to eq :test
    end

    it "doesn't allow arbitrary values" do
      expect {
        subject.environment = :foo
      }.to raise_error(ArgumentError)
    end

    it "accepts strings" do
      subject.environment = 'test'
      expect(subject.environment).to eq :test

      subject.environment = 'production'
      expect(subject.environment).to eq :production
    end
  end

  describe "#host" do
    context "with production environment" do
      subject { described_class.new({ environment: :production })}

      its(:host) { should eq 'https://checkout.klarna.com' }
    end

    context "with test environment" do
      subject { described_class.new({ environment: :test })}

      its(:host) { should eq 'https://checkout.testdrive.klarna.com' }
    end
  end

  describe "#create_order" do
    subject { described_class.new({shared_secret: 'foobar'}) }

    let(:order) { double('Order', to_json: JSON.generate({ foo: "bar" }), id: nil, :id= => true, valid?: true) }

    before(:each) do
      stub_request(:post, "https://checkout.testdrive.klarna.com/checkout/orders")
        .to_return(headers: { 'Location' => 'https://checkout.testdrive.klarna.com/checkout/orders/143F7BC0A1090B11C39E7220000' }, status: 201)
    end

    it "sends a json representation of the object to Klarna" do
      subject.create_order(order)

      assert_requested :post, "https://checkout.testdrive.klarna.com/checkout/orders",
        :headers => {
          # TODO: Investigate double definition in header
          # 'Accept' => 'application/vnd.klarna.checkout.aggregated-order-v2+json',
          'Authorization'  => 'Klarna dM+worqeBUs4UrOB3Jr/jSZWI39vP4LNw7NfDjGtW2w=',
          'Content-Type'   => 'application/vnd.klarna.checkout.aggregated-order-v2+json',
        },
        :body => JSON.generate({ foo: "bar" }),
        :times   => 1
    end

    it "checks the response" do
      expect(subject).to receive(:handle_status_code).with(201, '')
      subject.create_order(order)
    end

    it "returns the order" do
      return_value = subject.create_order(order)
      expect(return_value).to eq order
    end

    context "if the order is invalid" do
      before(:each) do
        allow(order).to receive(:valid?) { false }
      end

      it "returns a falsy value" do
        return_value = subject.create_order(order)
        expect(return_value).to be_falsey
      end
    end
  end

  describe "#handle_status_code" do
    context "with 200" do
      it "just yields the block given" do
        yielded = false
        subject.handle_status_code 200 do
          yielded = true
        end
        expect(yielded).to be_truthy
      end

      context "without block" do
        it "does nothing" do
          expect {
            subject.handle_status_code(200)
          }.to_not raise_error
        end
      end
    end

    context "with 201" do
      it "just yields the block given" do
        yielded = false
        subject.handle_status_code 201 do
          yielded = true
        end
        expect(yielded).to be_truthy
      end

      context "without block" do
        it "does nothing" do
          expect {
            subject.handle_status_code(201)
          }.to_not raise_error
        end
      end
    end


    context "with 401" do
      it "raises a Klarna::Checkout::UnauthorizedException" do
        expect {
          subject.handle_status_code(401)
        }.to raise_error(Klarna::Checkout::UnauthorizedException)
      end

      describe "handling status code with a message" do
        it "has a message" do
          begin
            subject.handle_status_code(401, 'foobar')
          rescue => e
            expect(e.message).to eq('foobar')
          end
        end
      end
    end

    context "with 403" do
      it "raises a Klarna::Checkout::ForbiddenException" do
        expect {
          subject.handle_status_code(403)
        }.to raise_error(Klarna::Checkout::ForbiddenException)
      end
    end

    context "with 404" do
      it "raises a Klarna::Checkout::NotFoundException" do
        expect {
          subject.handle_status_code(404)
        }.to raise_error(Klarna::Checkout::NotFoundException)
      end
    end

    context "with 405" do
      it "raises a Klarna::Checkout::MethodNotAllowedException" do
        expect {
          subject.handle_status_code(405)
        }.to raise_error(Klarna::Checkout::MethodNotAllowedException)
      end
    end

    context "with 406" do
      it "raises a Klarna::Checkout::NotAcceptableException" do
        expect {
          subject.handle_status_code(406)
        }.to raise_error(Klarna::Checkout::NotAcceptableException)
      end
    end

    context "with 415" do
      it "raises a Klarna::Checkout::UnsupportedMediaTypeException" do
        expect {
          subject.handle_status_code(415)
        }.to raise_error(Klarna::Checkout::UnsupportedMediaTypeException)
      end
    end

    context "with 500" do
      it "raises a Klarna::Checkout::InternalServerErrorException" do
        expect {
          subject.handle_status_code(500)
        }.to raise_error(Klarna::Checkout::InternalServerErrorException)
      end
    end
  end

  describe "#read_order" do
    subject { described_class.new({shared_secret: 'foobar'}) }

    before(:each) do
      stub_request(:get, "https://checkout.testdrive.klarna.com/checkout/orders/143F7BC0A1090B11C39E7220000")
        .to_return(body: JSON.generate({ id: "143F7BC0A1090B11C39E7220000" }))
    end

    it "uses the correct endpoint at klarna" do
      subject.read_order('143F7BC0A1090B11C39E7220000')

      assert_requested :get, "https://checkout.testdrive.klarna.com/checkout/orders/143F7BC0A1090B11C39E7220000",
        :headers => {
          # TODO: Investigate double definition in header
          # 'Accept' => 'application/vnd.klarna.checkout.aggregated-order-v2+json',
          'Authorization'  => 'Klarna w6uP8Tcg6K2QR905Rms8iXTlksL6OD1KOWBxTK7wxPI=',
        },
        :times   => 1
    end

    it "checks the response" do
      expect(subject).to receive(:handle_status_code).with(200, JSON.generate({ id: "143F7BC0A1090B11C39E7220000" }))
      subject.read_order('143F7BC0A1090B11C39E7220000')
    end
  end

  describe "#update_order" do
    subject { described_class.new({shared_secret: 'foobar'}) }
    let(:order) { double('Order', to_json: JSON.generate({ foo: "bar" }), :id => "143F7BC0A1090B11C39E7220000", valid?: true) }

    before(:each) do
      stub_request(:post, "https://checkout.testdrive.klarna.com/checkout/orders/143F7BC0A1090B11C39E7220000")
        .to_return(status: 200, body: JSON.generate({ id: "143F7BC0A1090B11C39E7220000" }))
    end

    it "uses the correct endpoint at klarna" do
      subject.update_order(order)

      assert_requested :post, "https://checkout.testdrive.klarna.com/checkout/orders/143F7BC0A1090B11C39E7220000",
        :headers => {
          # TODO: Investigate double definition in header
          # 'Accept' => 'application/vnd.klarna.checkout.aggregated-order-v2+json',
          'Authorization'  => 'Klarna dM+worqeBUs4UrOB3Jr/jSZWI39vP4LNw7NfDjGtW2w=',
          'Content-Type'   => 'application/vnd.klarna.checkout.aggregated-order-v2+json',
        },
        :times   => 1
    end

    it "checks the response" do
      expect(subject).to receive(:handle_status_code).with(200, JSON.generate({ id: "143F7BC0A1090B11C39E7220000" }))
      subject.update_order(order)
    end

    it "returns an order" do
      return_value = subject.update_order(order)
      expect(return_value).to be_kind_of(Klarna::Checkout::Order)
    end

    context "if the order is invalid" do
      before(:each) do
        allow(order).to receive(:valid?) { false }
      end

      it "returns a falsy value" do
        return_value = subject.update_order(order)
        expect(return_value).to be_falsey
      end
    end
  end

  describe "#sign_payload" do
    let(:client) { described_class.new(shared_secret: 'foobar') }

    context "when request body is empty" do
      subject { client.sign_payload }

      it { should eq "w6uP8Tcg6K2QR905Rms8iXTlksL6OD1KOWBxTK7wxPI=" }
    end

    context "when request body has some content" do
      subject { client.sign_payload('{"foo":"bar"}') }

      it { should eq "dM+worqeBUs4UrOB3Jr/jSZWI39vP4LNw7NfDjGtW2w=" }
    end
  end
end
