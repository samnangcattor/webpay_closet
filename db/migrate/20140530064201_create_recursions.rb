class CreateRecursions < ActiveRecord::Migration
  def change
    create_table :recursions do |t|
      t.references :customer, index: true
      t.references :item, index: true
      t.string :webpay_recursion_id
      t.string :period

      t.timestamps
    end
  end
end
