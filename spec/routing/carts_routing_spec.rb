require "rails_helper"

RSpec.describe CartsController, type: :routing do
  describe 'routes' do
    it 'routes to #show' do
      expect(get: '/cart/1').to route_to('carts#show', cart_id: '1')
    end

    it 'routes to #add_item via POST' do
      expect(post: '/cart').to route_to('carts#add_item')
    end

    it 'routes to #change_quantity via POST' do
      expect(post: '/cart/add_item').to route_to('carts#change_quantity')
    end

    it 'routes to #remove_item via DELETE' do
      expect(delete: '/cart/1').to route_to('carts#remove_item', product_id: '1')
    end
  end
end 
