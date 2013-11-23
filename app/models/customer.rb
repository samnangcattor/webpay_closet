class Customer < ActiveRecord::Base
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
end
