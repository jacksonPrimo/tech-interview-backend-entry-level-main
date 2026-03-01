require 'rails_helper'

RSpec.describe Cart, type: :model do
  context 'when validating' do
    it 'validates numericality of total_price' do
      cart = described_class.new(total_price: -1)
      expect(cart.valid?).to be_falsey
      expect(cart.errors[:total_price]).to include("must be greater than or equal to 0")
    end
  end

  # describe 'mark_as_abandoned' do
  #   let(:shopping_cart) { create(:cart) }

  #   it 'marks the shopping cart as abandoned if inactive for a certain time' do
  #     shopping_cart.update(last_interaction_at: 3.hours.ago)
  #     expect { shopping_cart.mark_as_abandoned }.to change { shopping_cart.abandoned? }.from(false).to(true)
  #   end
  # end

  describe 'add_item' do
    let(:shopping_cart) { create(:cart) }
    let(:product) { create(:product) }

    it 'adds an item and updates the carts last_interaction_at' do
      last_interaction_at_old = shopping_cart.last_interaction_at
      shopping_cart.add_item(product, 2)
      expect(shopping_cart.reload.last_interaction_at).to be > last_interaction_at_old
    end

    it 'updates the quantity of the existing item in the cart' do
      cart_item = create(:cart_item, cart: shopping_cart, product: product, quantity: 1)
      shopping_cart.add_item(product, 2)
      expect(cart_item.reload.quantity).to eq(2)
    end
  end

  describe 'remove_item' do
    let(:shopping_cart) { create(:cart) }
    let(:product) { create(:product, price: 50.0) }

    before do
      shopping_cart.add_item(product, 2)
    end

    it 'removes the item from the cart' do
      shopping_cart.remove_item(product)
      expect(shopping_cart.reload.cart_items.count).to eq(0)
    end

    it 'updates total_price correctly after removal' do
      expect(shopping_cart.reload.total_price).to eq(100.0)
      shopping_cart.remove_item(product)
      expect(shopping_cart.reload.total_price).to eq(0.0)
    end

    it 'updates last_interaction_at' do
      last_interaction_at_old = shopping_cart.reload.last_interaction_at
      shopping_cart.remove_item(product)
      expect(shopping_cart.reload.last_interaction_at).to be > last_interaction_at_old
    end
  end

  # describe 'remove_if_abandoned' do
  #   let(:shopping_cart) { create(:cart, last_interaction_at: 7.days.ago) }

  #   it 'removes the shopping cart if abandoned for a certain time' do
  #     shopping_cart.mark_as_abandoned
  #     expect { shopping_cart.remove_if_abandoned }.to change { Cart.count }.by(-1)
  #   end
  # end
end
