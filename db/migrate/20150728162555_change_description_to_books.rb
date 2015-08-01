class ChangeDescriptionToBooks < ActiveRecord::Migration
  def change
    rename_column :books, :descirption, :description
  end
end
