module CartServices
  class ShowCartService
    def initialize(cart_id:)
      @cart_id = cart_id
    end

    def call
      cart = find_cart
      format_response(cart)
    end

    private

    def format_response(cart)
      products = cart.cart_items.includes(:product).map do |item|
        prod = item.product
        {
          id: prod.id,
          name: prod.name,
          quantity: item.quantity,
          unit_price: prod.price,
          total_price: item.quantity * prod.price
        }
      end

      {
        id: cart.id,
        products: products,
        total_price: cart.total_price
      }
    end

    private

    def find_cart
      return raise CustomException.new('Cart not found', 404) if @cart_id.blank?

      cart = Cart.find_by(id: @cart_id) rescue nil
      raise CustomException.new('Cart not found', 404) if cart.blank?   

      cart
    end
  end
end
