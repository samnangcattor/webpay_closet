# -*- coding: utf-8 -*-
class ItemsController < ApplicationController
  # GET /items
  def index
    @items = Item.all
    @has_card = !!current_customer.try(:webpay_customer).try(:active_card)
  end

  # GET /items/:id/payment
  def payment
    @item = Item.find(params[:id])
  end

  # POST /items/:id/buy
  def buy
    item = Item.find(params[:id])
    if params['webpay-token']
      item.bought_by_guest(params['webpay-token'], params[:address], params[:name])
    else
      begin
        item.bought_by_customer(current_customer)
      rescue Customer::NoWebPayAccountError
        return redirect_to edit_customer_registration_path, notice: 'カード情報が未登録です'
      end
    end
    redirect_to items_path, notice: "#{item.name}を購入しました"
  rescue Item::TransactionFailed => e
    redirect_to items_path, notice: "支払いできませんでした (#{e.message})"
  end

  # POST /items/:id/buy_recursively
  def buy_recursively
    item = Item.find(params[:id])
    begin
      item.bought_recursively(current_customer)
    rescue Customer::NoWebPayAccountError
      return redirect_to edit_customer_registration_path, notice: 'カード情報が未登録です'
    end
    redirect_to items_path, notice: "#{item.name}を購入しました"
  rescue Item::TransactionFailed => e
    redirect_to items_path, notice: "支払いできませんでした (#{e.message})"
  end
end
