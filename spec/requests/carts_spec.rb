require 'rails_helper'

RSpec.describe "/carts", type: :request do
  describe "GET /" do
    let(:endpoint) { ->(cart_id) { "/cart/#{cart_id}" } }

    context 'failure cases' do
      it "failure if cart not found" do
        get endpoint.call(999999999999999999), as: :json
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body['error']).to eq('Cart not found')
      end
    end

    context 'success cases' do
      it "returns the cart and its products" do
        cart = create(:cart)
        product1 = create(:product, price: 10.0)
        product2 = create(:product, price: 5.0)
        create(:cart_item, cart: cart, product: product1, quantity: 2)
        create(:cart_item, cart: cart, product: product2, quantity: 1)
        cart.update_total!
        
        get endpoint.call(cart.id), as: :json
        expect(response).to have_http_status(:ok)
        
        response_body = response.parsed_body
        expect(response_body['id']).to eq(cart.id)
        expect(response_body['total_price']).to eq("25.0")
        expect(response_body['products'].size).to eq(2)
        
        expect(response_body['products'].first['id']).to eq(product1.id)
        expect(response_body['products'].first['quantity']).to eq(2)
        expect(response_body['products'].first['total_price']).to eq("20.0")

        expect(response_body['products'].last['id']).to eq(product2.id)
        expect(response_body['products'].last['quantity']).to eq(1)
        expect(response_body['products'].last['total_price']).to eq("5.0")
      end
    end
  end

  describe "POST /" do
    let(:endpoint) { '/cart' }

    context 'failure cases' do
      it 'failure if quantity is invalid type' do
        post endpoint, params: { cart_id: 1, product_id: 1, quantity: 'invalid' }, as: :json
        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body['error']).to eq('Quantity must be an integer')
      end

      it 'failure if quantity is less or equal 0' do
        post endpoint, params: { cart_id: 1, product_id: 1, quantity: 0 }, as: :json
        expect(response).to have_http_status(:bad_request)
        expect(response.parsed_body['error']).to eq('Quantity must be greater than 0')
      end

      it "failure if cart not found" do
        post endpoint, params: { cart_id: 999999999999999999, product_id: 1, quantity: 2 }, as: :json
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body['error']).to eq('Cart not found')
      end

      it "failure if product not found" do
        cart = create(:cart)
        post endpoint, params: { cart_id: cart.id, product_id: 999999999999999999, quantity: 2 }, as: :json
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body['error']).to eq('Product not found')
      end
    end

    context 'success cases' do
      it "update the quantity of the existing item in the cart" do
        cart = create(:cart)
        product = create(:product)
        cart_item = create(:cart_item, cart: cart, product: product, quantity: 1)
        post endpoint, params: { cart_id: cart.id, product_id: product.id, quantity: 2 }, as: :json
        expect(cart_item.reload.quantity).to eq(2)
        expect(response).to have_http_status(:ok)
        response_body = response.parsed_body
        expect(response_body['id']).to eq(cart.id)
        expect(response_body['total_price']).to eq("20.0")

        product_data = response_body['products'].first
        expect(product_data['id']).to eq(product.id)
        expect(product_data['name']).to eq(product.name)
        expect(product_data['quantity']).to eq(2)
        expect(product_data['unit_price']).to eq("10.0")
        expect(product_data['total_price']).to eq("20.0")
      end

      it "when cart id not exist yet, create a new cart" do
        product = create(:product)
        post endpoint, params: { product_id: product.id, quantity: 2 }, as: :json
        expect(response).to have_http_status(:ok)
        response_body = response.parsed_body
        expect(response_body['id']).to eq(Cart.last.id)
        expect(response_body['total_price']).to eq("20.0")

        product_data = response_body['products'].first
        expect(product_data['id']).to eq(product.id)
        expect(product_data['name']).to eq(product.name)
        expect(product_data['quantity']).to eq(2)
        expect(product_data['unit_price']).to eq("10.0")
        expect(product_data['total_price']).to eq("20.0")
      end
    end
  end

  describe "DELETE /:product_id" do
    let(:endpoint) { ->(product_id) { "/cart/#{product_id}" } }

    context 'failure cases' do
      it "failure if cart not found" do
        delete endpoint.call(1), params: { cart_id: 999999999999999999 }, as: :json
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body['error']).to eq('Cart not found')
      end

      it "failure if product not found in database" do
        cart = create(:cart)
        delete endpoint.call(999999999999999999), params: { cart_id: cart.id }, as: :json
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body['error']).to eq('Product not found')
      end

      it "failure if product not found in cart" do
        cart = create(:cart)
        product = create(:product)
        delete endpoint.call(product.id), params: { cart_id: cart.id }, as: :json
        expect(response).to have_http_status(:not_found)
        expect(response.parsed_body['error']).to eq('Product not found in cart')
      end
    end

    context 'success cases' do
      it "removes the item from the cart and returns updated payload" do
        cart = create(:cart)
        product1 = create(:product, price: 10.0)
        product2 = create(:product, price: 5.0)
        create(:cart_item, cart: cart, product: product1, quantity: 2)
        create(:cart_item, cart: cart, product: product2, quantity: 1)
        cart.update_total!
        
        expect(cart.cart_items.count).to eq(2)
        expect(cart.total_price).to eq(25.0)

        delete endpoint.call(product1.id), params: { cart_id: cart.id }, as: :json
        expect(response).to have_http_status(:ok)
        
        response_body = response.parsed_body
        expect(response_body['id']).to eq(cart.id)
        expect(response_body['total_price']).to eq("5.0")
        expect(response_body['products'].size).to eq(1)
        expect(response_body['products'].first['id']).to eq(product2.id)
      end
    end
  end
end
