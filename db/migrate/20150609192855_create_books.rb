class CreateBooks < ActiveRecord::Migration
  def change
    create_table :books do |t|
      t.string :title
      t.text :descirption
      t.float :price
      t.integer :books_in_stock
      t.belongs_to :category, index: true
      t.belongs_to :author, index: true

      t.timestamps null: false
    end
  end
end
