require 'rails_helper'

RSpec.describe "/carts", type: :request do
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
end
