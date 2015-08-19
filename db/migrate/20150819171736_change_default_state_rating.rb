class ChangeDefaultStateRating < ActiveRecord::Migration
  def up
    change_column :ratings, :state, :string, default: "not_approved"
    Rating.update_all ["state = ?", "not_approved"]
  end

  def down
    change_column :ratings, :state, :string, default: "not approved"
    Rating.update_all ["state = ?", "not approved"]
  end
end
