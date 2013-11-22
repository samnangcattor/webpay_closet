class Customer < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :validatable
end
