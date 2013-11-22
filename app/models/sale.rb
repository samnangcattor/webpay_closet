class Sale < ActiveRecord::Base
  belongs_to :customer
  belongs_to :item

  validates_presence_of :customer, :item, :webpay_charge_id
end
