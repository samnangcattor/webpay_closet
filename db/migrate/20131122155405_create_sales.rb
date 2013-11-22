class CreateSales < ActiveRecord::Migration
  def change
    create_table :sales do |t|
      t.references :customer, index: true
      t.references :item, index: true
      t.string :webpay_charge_id, null: false

      t.timestamps
    end
  end
end
