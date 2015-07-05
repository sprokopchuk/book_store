class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.float :total_price, default: 0
      t.date :completed_date
      t.string :state, default: "in progress"
      t.belongs_to :credit_card
      t.belongs_to :customer

      t.timestamps null: false
    end
  end
end
