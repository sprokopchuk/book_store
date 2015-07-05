class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.string :address
      t.integer :zipcode
      t.string :city
      t.string :phone
      t.belongs_to :country, index:true

      t.timestamps null: false
    end
  end
end
