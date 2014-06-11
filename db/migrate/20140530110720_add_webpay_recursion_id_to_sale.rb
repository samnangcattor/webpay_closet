class AddWebpayRecursionIdToSale < ActiveRecord::Migration
  def change
    add_column :sales, :webpay_recursion_id, :string
  end
end
