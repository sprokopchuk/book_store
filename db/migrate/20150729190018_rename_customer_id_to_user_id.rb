class RenameCustomerIdToUserId < ActiveRecord::Migration
  def change
    rename_column :credit_cards, :customer_id, :user_id
    rename_column :orders, :customer_id, :user_id
    rename_column :ratings, :customer_id, :user_id
  end
end
