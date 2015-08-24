class ChangeRelationsAddressToUsers < ActiveRecord::Migration
  def change
    add_column :addresses, :user_id, :integer
    add_column :addresses, :billing_address, :boolean
    add_column :addresses, :shipping_address, :boolean
    add_index :addresses, :user_id
  end
end
