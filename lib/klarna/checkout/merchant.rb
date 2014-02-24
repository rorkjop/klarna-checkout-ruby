require 'active_model'

module Klarna
  module Checkout
    class Merchant < Resource
      include ActiveModel::Validations

      attr_accessor :id, :terms_uri, :checkout_uri, :confirmation_uri,
                    :push_uri, :validation_uri

      validates_presence_of :id, :terms_uri, :checkout_uri, :confirmation_uri,
                            :push_uri

      def as_json
        json_sanitize({
          :id               => @id,
          :terms_uri        => @terms_uri,
          :checkout_uri     => @checkout_uri,    
          :confirmation_uri => @confirmation_uri,        
          :push_uri         => @push_uri,
          :validation_uri   => @validation_uri
        })
      end
    end
  end
end
