require 'rails_helper'

feature 'Books' do

  given!(:book) {FactoryGirl.create :book}

  scenario 'search by category' do
    visit books_path
    click_link("#{book.category.title}")
    expect(page).to have_link("#{book.title}", href: book_path(book))
  end

  scenario 'search by form' do
    visit root_path
    fill_in "search", with: book.author.first_name
    click_button "Search"
    expect(page).to have_link("#{book.title}", href: book_path(book))
  end

end
