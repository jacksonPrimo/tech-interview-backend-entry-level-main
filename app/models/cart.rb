class Cart < ApplicationRecord
  validates_numericality_of :total_price, greater_than_or_equal_to: 0
  has_many :cart_items

  # TODO: lógica para marcar o carrinho como abandonado e remover se abandonado

  def add_item(product, quantity)
    ActiveRecord::Base.transaction do
      item = self.cart_items.find_or_initialize_by(product_id: product.id)
      item.quantity = quantity
      item.save!
      update_total!      
    end
  end

  def update_total!
    total = cart_items.joins(:product).sum('cart_items.quantity * products.price')    
    update!(total_price: total)
  end
end
