class Recursion < ActiveRecord::Base
  belongs_to :customer
  belongs_to :item

  validates_presence_of :customer, :item, :webpay_recursion_id, :period

  def webpay_recursion
    @webpay_recursion ||= WebPay::Recursion.retrieve(webpay_recursion_id)
  end

  def next_scheduled
    Time.at(webpay_recursion.next_scheduled)
  end

  def destroy
    webpay_recursion.delete
    super
  end
end
