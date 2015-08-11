class ChangeNameDefaultStateToOrders < ActiveRecord::Migration
  def up
    change_column :orders, :state, :string, default: "in_progress"
    Order.update_all ["state = ?", "in_progress"]
  end

  def down
    change_column :orders, :state, :string, default: "in progress"
    Order.update_all ["state = ?", "in progress"]
  end
end
