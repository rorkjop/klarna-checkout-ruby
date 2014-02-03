require 'digest/sha2'
require 'base64'
require 'faraday'

module Klarna
  module Checkout
    class Client
      attr_accessor :shared_secret

      def initialize(args = {})
        args.each do |(k,v)|
          self.public_send("#{k}=", v)
        end        
      end

      def create_order(order)
        request_body = order.to_json
        response = https_connection.post do |req|
          req.url '/checkout/orders'

          req.headers['Authorization']   = "Klarna #{sign_payload(request_body)}"
          req.headers['Accept']          = 'application/vnd.klarna.checkout.aggregated-order-v2+json',
          req.headers['Content-Type']    = 'application/vnd.klarna.checkout.aggregated-order-v2+json'
          req.headers['Accept-Encoding'] = ''

          req.body = request_body
        end
        order.id = response.headers['Location'].split('/').last
        order
      end

      def read_order(id) 
        response = https_connection.get do |req|
          req.url "/checkout/orders/#{id}"

          req.headers['Authorization']   = "Klarna #{sign_payload}"
          req.headers['Accept']          = 'application/vnd.klarna.checkout.aggregated-order-v2+json'
          req.headers['Accept-Encoding'] = ''
        end
        Order.new(JSON.parse(response.body))
      end

      # Based on example from:
      # http://developers.klarna.com/en/api-references-v1/klarna-checkout#authorization
      def sign_payload(request_body = '')
        payload = "#{request_body}#{shared_secret}"
        Digest::SHA256.base64digest(payload)
      end

      private

      def https_connection
        @https_connection ||= Faraday.new(url: 'https://checkout.testdrive.klarna.com')
      end
    end
  end
end
