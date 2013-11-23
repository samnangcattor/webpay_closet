class Customer < ActiveRecord::Base
  class NoWebPayAccountError < RuntimeError
  end
  class ChargeFailed < RuntimeError
    attr_reader :error
    def initialize(error)
      super(error.message)
      @error = error
    end
  end

  devise :database_authenticatable, :registerable, :validatable

  attr_accessor :webpay_token

  def update_webpay_customer_id
    return if self.webpay_customer_id.nil? && webpay_token.blank?

    if self.webpay_customer_id
      retrieved = WebPay::Customer.retrieve(self.webpay_customer_id)
      retrieved.card = self.webpay_token if webpay_token.present?
      retrieved.email = self.email
      retrieved.description = self.name
      retrieved.save
    else
      created = WebPay::Customer.create(card: webpay_token, email: self.email, description: self.name)
      update_attributes(webpay_customer_id: created.id)
    end
  end

  def buy(item)
    raise NoWebPayAccountError.new if self.webpay_customer_id.blank?
    begin
      charge = WebPay::Charge.create(customer: self.webpay_customer_id, amount: item.price, currency: Item::CURRENCY)
      Sale.create(customer: self, item: item, webpay_charge_id: charge.id)
    rescue WebPay::WebPayError => e
      raise ChargeFailed.new(e)
    end
  end
end
