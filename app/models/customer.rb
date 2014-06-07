class Customer < ActiveRecord::Base
  class NoWebPayAccountError < RuntimeError
  end
  include WebPayClient

  devise :database_authenticatable, :registerable, :validatable

  attr_accessor :webpay_token

  def update_webpay_customer_id
    return if self.webpay_customer_id.nil? && webpay_token.blank?

    if self.webpay_customer_id
      req = { id: self.webpay_customer_id }
      req[:card] = self.webpay_token if webpay_token.present?
      req[:email] = self.email if self.email
      req[:description] = self.name if self.name
      webpay.customer.update(req)
    else
      created = webpay.customer.create(card: webpay_token, email: self.email, description: self.name)
      update_attributes(webpay_customer_id: created.id)
    end
  end

  def webpay_customer_id_or_raise
    self.webpay_customer_id.presence or raise NoWebPayAccountError.new
  end
end
