class ChangeStockToBooks < ActiveRecord::Migration
  def change
    rename_column :books, :books_in_stock, :in_stock
  end
end
