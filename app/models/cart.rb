class Cart < ApplicationRecord
  validates_numericality_of :total_price, greater_than_or_equal_to: 0
  has_many :cart_items

  def mark_as_abandoned
    update!(abandoned: true) if last_interaction_at && last_interaction_at <= 3.hours.ago
  end

  def remove_if_abandoned
    destroy! if abandoned? && last_interaction_at && last_interaction_at <= 7.days.ago
  end

  def add_item(product, quantity)
    ActiveRecord::Base.transaction do
      item = self.cart_items.find_or_initialize_by(product_id: product.id)
      item.quantity = quantity
      item.save!
      update_total!
    end
  end

  def remove_item(product)
    ActiveRecord::Base.transaction do
      item = self.cart_items.find_by(product_id: product.id)
      item&.destroy!
      update_total!
    end
  end

  def change_item_quantity(product, new_quantity)
    ActiveRecord::Base.transaction do
      item = self.cart_items.find_by!(product_id: product.id)
      item.update!(quantity: new_quantity)
      update_total!
    end
  end

  def update_total!
    total = cart_items.joins(:product).sum('cart_items.quantity * products.price')    
    update!(total_price: total, last_interaction_at: Time.current, abandoned: false)
  end
end
