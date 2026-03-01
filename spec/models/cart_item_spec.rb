require 'rails_helper'

RSpec.describe CartItem, type: :model do
  context 'associations' do
    it 'belongs to a cart' do
      association = described_class.reflect_on_association(:cart)
      expect(association.macro).to eq(:belongs_to)
    end

    it 'belongs to a product' do
      association = described_class.reflect_on_association(:product)
      expect(association.macro).to eq(:belongs_to)
    end
  end

  context 'validations' do
    it 'is valid with valid attributes' do
      cart = create(:cart)
      product = create(:product)
      cart_item = CartItem.new(cart: cart, product: product, quantity: 2)
      expect(cart_item).to be_valid
    end
  end
end
