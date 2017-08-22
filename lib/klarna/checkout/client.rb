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
          raise ArgumentError, "Environment must be one of: #{VALID_ENVS.join(', ')}"
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
        return false unless order.valid?

        response = write_order(order)
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
        handle_status_code(response.status, response.body)

        Order.new(JSON.parse(response.body))
      end

      def update_order(order)
        return false unless order.valid?

        response = write_order(order)
        Order.new(JSON.parse(response.body))
      end

      # Based on example from:
      # http://developers.klarna.com/en/api-references-v1/klarna-checkout#authorization
      def sign_payload(request_body = '')
        payload = "#{request_body}#{shared_secret}"
        Digest::SHA256.base64digest(payload)
      end

      def handle_status_code(code, msg = nil)
        case Integer(code)
          when 200, 201
            yield if block_given?
          when 400
            raise Klarna::Checkout::BadRequest.new(msg)
          when 401
            raise Klarna::Checkout::UnauthorizedException.new(msg)
          when 403
            raise Klarna::Checkout::ForbiddenException.new(msg)
          when 404
            raise Klarna::Checkout::NotFoundException.new(msg)
          when 405
            raise Klarna::Checkout::MethodNotAllowedException.new(msg)
          when 406
            raise Klarna::Checkout::NotAcceptableException.new(msg)
          when 415
            raise Klarna::Checkout::UnsupportedMediaTypeException.new(msg)
          when 500
            raise Klarna::Checkout::InternalServerErrorException.new(msg)
        end
      end

      private

      def write_order(order)
        path  = "/checkout/orders"
        path += "/#{order.id}" if order.id

        request_body = order.to_json
        response = https_connection.post do |req|
          req.url path

          req.headers['Authorization']   = "Klarna #{sign_payload(request_body)}"
          req.headers['Accept']          = 'application/vnd.klarna.checkout.aggregated-order-v2+json'
          req.headers['Content-Type']    = 'application/vnd.klarna.checkout.aggregated-order-v2+json'
          req.headers['Accept-Encoding'] = ''

          req.body = request_body
        end
        handle_status_code(response.status, response.body)
        response
      end

      def https_connection
        @https_connection ||= Faraday.new(url: host)
      end
    end
  end
end
