class Customer < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :validatable

  attr_accessor :webpay_token

  def update_webpay_customer_id
    return if webpay_token.blank?

    created = WebPay::Customer.create(card: webpay_token, email: self.email, description: self.name)
    update_attributes(webpay_customer_id: created.id)
  end
end
