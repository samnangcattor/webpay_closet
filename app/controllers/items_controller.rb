class ItemsController < ApplicationController
  before_filter :authenticate_customer!, only: [:buy]

  # GET /items
  def index
    @items = Item.all
  end

  # POST /items/:id/buy
  def buy
    item = Item.find(params[:id])
    current_customer.buy(item)
    redirect_to :index
  end
end
