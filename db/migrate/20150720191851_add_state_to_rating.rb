class AddStateToRating < ActiveRecord::Migration
  def change
    add_column :ratings, :state, :string, default: "not approved"
  end
end
