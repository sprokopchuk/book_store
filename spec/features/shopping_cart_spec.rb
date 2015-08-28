require 'rails_helper'

feature 'Shopping cart' do
  given(:user) {FactoryGirl.create :user}
  given(:order_in_progress) {FactoryGirl.create :order, user: user}
  given(:book) {FactoryGirl.create :book}
  given(:order_item) {FactoryGirl.create :order_item, book: book}

  background do
    login_as user, scope: :user
  end

  scenario 'add successfully book to cart' do
    visit book_path(book)
    click_button I18n.t("books.add_to_card")
    expect(page).to have_content(I18n.t("order_items.add_success"))
    expect(page).to have_link(I18n.t("header.cart")+" ($#{book.price})", href: shopping_cart_path)
  end

  scenario 'see book in the cart' do
    order_in_progress.add order_item
    visit shopping_cart_path
    expect(page).to have_link("#{book.title}", href: book_path(book))
  end

  scenario 'update quantity of books' do
    order_in_progress.add order_item
    visit shopping_cart_path
    within "#edit_order_#{order_in_progress.id}" do
      fill_in "order[order_items_attributes][0][quantity]", with: 3
    end
    click_button I18n.t("current_order.update")
    expect(page).to have_content(I18n.t("current_order.update_success"))
    expect(page).to have_content("#{order_in_progress.real_price}")
  end

  scenario 'remove the book from cart' do
    order_in_progress.add order_item
    visit shopping_cart_path
    click_link(I18n.t("current_order.remove"), href: order_item_path(order_item))
    expect(page).to have_content(I18n.t("order_items.destroy_item"))
    expect(page).not_to have_link("#{book.title}", href: book_path(book))
  end

  scenario 'empty shopping cart' do
    order_in_progress.add order_item
    visit shopping_cart_path
    click_link(I18n.t("current_order.empty_cart"), href: destroy_all_order_items_path)
    expect(page).to have_content(I18n.t("order_items.destroy_all_items"))
    expect(page).not_to have_link("#{book.title}", href: book_path(book))
  end

  scenario "to checkout order" do
    order_in_progress.add order_item
    visit shopping_cart_path
    click_link(I18n.t("current_order.checkout"))
    expect(current_path).to eq address_checkout_path
    end


  feature 'checkout order' do
    given(:user) {FactoryGirl.create :user}
    given(:order_in_progress) {FactoryGirl.create :order, user: user}
    given(:book) {FactoryGirl.create :book}
    given(:order_item) {FactoryGirl.create :order_item, book: book}

    given(:billing_address) {FactoryGirl.attributes_for :billing_address, country_id: countries[0].id}
    given(:shipping_address) {FactoryGirl.attributes_for :shipping_address, country_id: countries[0].id}
    given!(:countries) {FactoryGirl.create_list :country, 3}
    given!(:deliveries) {FactoryGirl.create_list :delivery, 3}
    given(:credit_card) {FactoryGirl.attributes_for :credit_card, :exp_year=>2016}
    before do
      order_in_progress.add order_item
    end
    scenario 'fill in addresses' do
      visit address_checkout_path
      fill_in_address(billing_address, "billing")
      fill_in_address(shipping_address, "shipping")
      click_button(I18n.t("checkout_order.save_and_continue"))
      expect(current_path).to eq delivery_checkout_path
    end

    scenario "choose delivery" do
      visit address_checkout_path
      fill_in_address(billing_address, "billing")
      fill_in_address(shipping_address, "shipping")
      click_button(I18n.t("checkout_order.save_and_continue"))
      choose deliveries[2].name
      click_button(I18n.t("checkout_order.save_and_continue"))
      expect(current_path).to eq payment_checkout_path
    end

    scenario 'fill in payment information' do
      visit address_checkout_path
      fill_in_address(billing_address, "billing")
      fill_in_address(shipping_address, "shipping")
      click_button(I18n.t("checkout_order.save_and_continue"))
      choose deliveries[2].name
      click_button(I18n.t("checkout_order.save_and_continue"))
      fill_in_payment credit_card, user
      click_button(I18n.t("checkout_order.save_and_continue"))
      order_in_progress.reload
      p order_in_progress.credit_card
      p user.credit_card
      expect(current_path).to eq confirm_checkout_path
    end

    scenario 'confirm order' do

    end
  end



end
