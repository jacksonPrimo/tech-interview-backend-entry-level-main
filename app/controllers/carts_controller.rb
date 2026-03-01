class CartsController < ApplicationController
  def show
    cart = ::CartServices::ShowCartService.new(
      cart_id: params[:cart_id]
    ).call

    render json: cart, status: :ok
  end

  def add_item    
    cart = ::CartServices::AddItemService.new(
      cart_id: params[:cart_id],
      product_id: params[:product_id],
      quantity: params[:quantity]
    ).call
    
    render json: cart, status: :ok
  end

  def remove_item
    cart = ::CartServices::RemoveItemService.new(
      cart_id: params[:cart_id],
      product_id: params[:product_id]
    ).call

    render json: cart, status: :ok
  end
end
