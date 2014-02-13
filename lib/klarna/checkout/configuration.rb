module Klarna
  module Checkout
    module Configuration
      def shared_secret=(shared_secret)
        @@shared_secret = shared_secret
      end

      def shared_secret
        @@shared_secret rescue nil
      end

      def merchant_id=(merchant_id)
        @@merchant_id = merchant_id
      end

      def merchant_id
        @@merchant_id rescue nil
      end

      def configure(&blk)
        yield(self)
      end

      def reset_configuration!
        @@shared_secret = nil
        @@merchant_id   = nil
      end
    end
  end
end
