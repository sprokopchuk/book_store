require 'rails_helper'

feature 'WishList' do

  given(:user) {FactoryGirl.create(:user)}
  given(:list_books) {FactoryGirl.create_list :book, 5}

  background do
    login_as user, scope: :user
  end

  scenario 'add successfully book to wish list' do
    visit book_path(list_books[0])
    click_button I18n.t("books.add_to_wishlist")
    expect(page).to have_content(I18n.t("wish_list.add_success"))
    expect(page).to have_content(I18n.t("wish_list.already_in_list"))
  end

  scenario 'see added book in wish list' do
    user.wish_list.books << list_books
    visit user_wish_list_path(user)
    expect(page).to have_link(list_books[3].title, :href => book_path(list_books[3]))
  end

  scenario 'remove book successfully from wish list' do
    user.wish_list.books << list_books
    visit user_wish_list_path(user)
    within all('form').last do
      click_button I18n.t("wish_list.remove_button")
    end
    expect(page).to have_content(I18n.t("wish_list.remove_success"))
    expect(page).not_to have_link(list_books[4].title, :href => book_path(list_books[4]))
  end
end
