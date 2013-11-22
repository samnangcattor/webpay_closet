class DeviseCreateCustomers < ActiveRecord::Migration
  def change
    create_table(:customers) do |t|
      ## Database authenticatable
      t.string :email,              :null => false, :default => ""
      t.string :encrypted_password, :null => false, :default => ""

      t.string :name, null: false
      t.string :webpay_customer_id
      t.string :address, null: false
      t.boolean :disabled, default: false

      t.timestamps
    end

    add_index :customers, :email,                :unique => true
    add_index :customers, :webpay_customer_id,   :unique => true
  end
end
