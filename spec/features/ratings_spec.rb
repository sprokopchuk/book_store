require 'rails_helper'

feature 'Rating' do

  given(:user) {FactoryGirl.create(:user)}
  given(:book) {FactoryGirl.create(:book)}

  background do
    login_as user, scope: :user
    visit book_path(book)
  end

  scenario 'add successfully with flash message' do
    within "#new_rating" do
      fill_in "rating[rate]", with: 3
      fill_in "rating[review]", with: Faker::Lorem.sentence
      click_button I18n.t("books.add_rating")
    end
    expect(page).to have_content(I18n.t("ratings.add_success"))
  end
end
