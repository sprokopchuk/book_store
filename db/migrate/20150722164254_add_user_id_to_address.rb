class AddUserIdToAddress < ActiveRecord::Migration
  def change
    add_column :addresses, :billing_address_id, :integer
    add_column :addresses, :shipping_address_id, :integer
    add_index :addresses, :billing_address_id
    add_index :addresses, :shipping_address_id
  end
end
