# -*- coding: utf-8 -*-
class ItemsController < ApplicationController
  before_filter :authenticate_customer!, only: [:buy]

  # GET /items
  def index
    @items = Item.all
  end

  # GET /items/:id/payment
  def payment
    @item = Item.find(params[:id])
  end

  # POST /items/:id/buy
  def buy
    item = Item.find(params[:id])
    current_customer.buy(item)
    redirect_to items_path, notice: "#{item.name}を購入しました"
  rescue Customer::NoWebPayAccountError
    redirect_to edit_customer_registration_path, notice: 'カード情報が未登録です'
  rescue Customer::ChargeFailed => e
    redirect_to items_path, notice: "支払いできませんでした (#{e.message})"
  end
end
