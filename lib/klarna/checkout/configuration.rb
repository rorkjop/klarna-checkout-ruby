module Klarna
  module Checkout
    module Configuration
      def shared_secret=(shared_secret)
        @@shared_secret = shared_secret
      end

      def shared_secret
        @@shared_secret
      end

      def merchant_id=(merchant_id)
        @@merchant_id = merchant_id
      end

      def merchant_id
        @@merchant_id
      end

      def configure(&blk)
        yield(self)
      end
    end
  end
end
