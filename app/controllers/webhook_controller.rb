class WebhookController < ApplicationController
  def index
    if params[:type] == 'charge.succeeded' &&
        recursion = Recursion.find_by(webpay_recursion_id: params[:data][:object][:recursion])

      Sale.create(
        customer: recursion.customer,
        item: recursion.item,
        webpay_charge_id: params[:data][:object][:id],
        webpay_recursion_id: recursion.webpay_recursion_id
      )
    end
    head :ok
  end
end
