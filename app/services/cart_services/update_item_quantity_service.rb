module CartServices
  class UpdateItemQuantityService
    def initialize(cart_id:, product_id:, quantity:)
      @cart_id = cart_id
      @product_id = product_id
      @quantity = quantity
    end

    def call
      validate_quantity
      cart = find_cart
      product = find_product_in_cart(cart)
      
      cart.change_item_quantity(product, @quantity)
      
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

    def validate_quantity
      raise CustomException.new('Quantity must be an integer', 400) unless @quantity.is_a?(Integer)
      raise CustomException.new('Quantity must be greater than 0', 400) if @quantity <= 0
    end

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
