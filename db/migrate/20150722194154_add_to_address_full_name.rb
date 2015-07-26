class AddToAddressFullName < ActiveRecord::Migration
  def change
    add_column :addresses, :first_name, :string
    add_column :addresses, :last_name, :string
    remove_column :users, :first_name
    remove_column :users, :last_name
  end
end
