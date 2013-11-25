# -*- coding: utf-8 -*-
class ItemsController < ApplicationController
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
    if current_customer
      begin
        current_customer.buy(item)
      rescue Customer::NoWebPayAccountError
        return redirect_to edit_customer_registration_path, notice: 'カード情報が未登録です'
      rescue Customer::ChargeFailed => e
        return redirect_to items_path, notice: "支払いできませんでした (#{e.message})"
      end
    else
      begin
        item.bought_by_guest(params['webpay-token'], params[:address], params[:name])
      rescue Item::ChargeFailed => e
        return redirect_to items_path, notice: "支払いできませんでした (#{e.message})"
      end
    end
    redirect_to items_path, notice: "#{item.name}を購入しました"
  end
end
