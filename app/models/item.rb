class Item < ActiveRecord::Base
  CURRENCY = 'jpy'.freeze

  validates_presence_of :name, :price
  validates_uniqueness_of :name
  validates_numericality_of :price, greater_than: 0
end
