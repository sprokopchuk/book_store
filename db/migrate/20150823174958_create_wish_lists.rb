class CreateWishLists < ActiveRecord::Migration
  def change
    create_table :wish_lists do |t|
      t.belongs_to :user, index: true
    end

    create_join_table :books, :wish_lists
  end
end
