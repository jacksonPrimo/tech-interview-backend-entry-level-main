module CartServices
  class RemoveItemService
    def initialize(cart_id:, product_id:)
      @cart_id = cart_id
      @product_id = product_id
    end

    def call
      cart = find_cart
      product = find_product_in_cart(cart)
      cart.remove_item(product)
      
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

    def find_product_in_cart(cart)
      product = Product.find(@product_id) rescue nil
      raise CustomException.new('Product not found', 404) if product.blank?

      cart_item = cart.cart_items.find_by(product_id: product.id)
      raise CustomException.new('Product not found in cart', 404) if cart_item.blank?

      product
    end
  end
end
