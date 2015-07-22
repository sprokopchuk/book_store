class AddCutomerIdToAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :customer_billing_address_id, :integer
    add_column :addresses, :customer_shipping_address_id, :integer
    add_index :addresses, :customer_billing_address_id
    add_index :addresses, :customer_shipping_address_id
  end
end
