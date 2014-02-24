require 'digest/sha2'
require 'base64'
require 'faraday'

require 'klarna/checkout/exceptions'

module Klarna
  module Checkout
    class Client
      attr_accessor :shared_secret, :environment

      def initialize(args = {})
        args.each do |(k,v)|
          self.public_send("#{k}=", v)
        end
        self.shared_secret ||= Klarna::Checkout.shared_secret
      end

      VALID_ENVS = [:test, :production]

      def environment
        @environment || :test
      end

      def environment=(new_env)
        new_env = new_env.to_sym
        unless VALID_ENVS.include?(new_env)
          raise "Environment must be one of: #{VALID_ENVS.join(', ')}"
        end

        @environment = new_env
      end

      def host
        if environment == :production
          'https://checkout.klarna.com'
        else
          'https://checkout.testdrive.klarna.com'
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
        handle_status_code(response.status)

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
        handle_status_code(response.status)

        Order.new(JSON.parse(response.body))
      end

      def update_order(order)
        request_body = order.to_json
        response = https_connection.post do |req|
          req.url "/checkout/orders/#{order.id}"

          req.headers['Authorization']   = "Klarna #{sign_payload(request_body)}"
          req.headers['Accept']          = 'application/vnd.klarna.checkout.aggregated-order-v2+json',
          req.headers['Content-Type']    = 'application/vnd.klarna.checkout.aggregated-order-v2+json'
          req.headers['Accept-Encoding'] = ''

          req.body = request_body
        end
        handle_status_code(response.status)

        Order.new(JSON.parse(response.body))
      end

      # Based on example from:
      # http://developers.klarna.com/en/api-references-v1/klarna-checkout#authorization
      def sign_payload(request_body = '')
        payload = "#{request_body}#{shared_secret}"
        Digest::SHA256.base64digest(payload)
      end

      def handle_status_code(code, &blk)
        case Integer(code)
        when 200, 201
          yield if block_given?
        when 401
          raise Klarna::Checkout::UnauthorizedException.new
        when 403
          raise Klarna::Checkout::ForbiddenException.new
        when 404
          raise Klarna::Checkout::NotFoundException.new
        when 405
          raise Klarna::Checkout::MethodNotAllowedException.new
        when 406
          raise Klarna::Checkout::NotAcceptableException.new
        when 415
          raise Klarna::Checkout::UnsupportedMediaTypeException.new
        when 500
          raise Klarna::Checkout::InternalServerErrorException.new
        end
      end

      private

      def https_connection
        @https_connection ||= Faraday.new(url: host)
      end
    end
  end
end
