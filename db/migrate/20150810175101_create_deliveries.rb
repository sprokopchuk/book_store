class CreateDeliveries < ActiveRecord::Migration
  def change
    create_table :deliveries do |t|
      t.string :name
      t.float :price

      t.timestamps null: false
    end

    add_column :orders, :delivery_id, :integer

  end
end
