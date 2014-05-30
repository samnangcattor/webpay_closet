class Item < ActiveRecord::Base
  CURRENCY = 'jpy'.freeze
  class TransactionFailed < RuntimeError
    attr_reader :error
    def initialize(error)
      super(error.message)
      @error = error
    end
  end

  validates_presence_of :name, :price
  validates_uniqueness_of :name
  validates_numericality_of :price, greater_than: 0

  def bought_by_customer(customer)
    charge = WebPay::Charge.create(
      customer: customer.webpay_customer_id_or_raise,
      amount: self.price,
      currency: CURRENCY
    )

    Sale.create(
      customer: customer,
      item: self,
      webpay_charge_id: charge.id
    )
  rescue WebPay::WebPayError => e
    raise TransactionFailed.new(e)
  end

  def bought_by_guest(token, address = nil, name = nil)
    description = [address, name].map { |n| n.presence || '' }.join(' ')
    WebPay::Charge.create(
      card: token,
      amount: self.price,
      currency: CURRENCY,
      description: description
    )
  rescue WebPay::WebPayError => e
    raise TransactionFailed.new(e)
  end

  def bought_recursively(customer)
    recursion = WebPay::Recursion.create(
      customer: customer.webpay_customer_id_or_raise,
      amount: self.price,
      currency: CURRENCY,
      period: "month"
    )

    Recursion.create(
      customer: customer,
      item: self,
      webpay_recursion_id: recursion.id,
      period: "month"
    )
  rescue WebPay::WebPayError => e
    raise TransactionFailed.new(e)
  end
end
