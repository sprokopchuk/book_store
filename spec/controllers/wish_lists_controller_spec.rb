require 'rails_helper'
RSpec.describe WishListsController, type: :controller do
  let(:book) {FactoryGirl.create :book}
  let(:user) {FactoryGirl.build_stubbed :user}
  let(:wish_list) {FactoryGirl.build_stubbed :wish_list, user: user}

  before do
    request.env["HTTP_REFERER"] = "localhost:3000/where_i_came_from"
    allow(controller).to receive(:current_or_guest_user).and_return user
    allow(user).to receive(:wish_list).and_return wish_list
    allow(controller).to receive(:authenticate_user!).and_return true
  end

  describe 'GET #show' do

    it "renders :show template" do
      get :show, user_id: user.id
      expect(response).to render_template :show
    end
  end

  describe "POST #add_book" do
    before do
      allow(Book).to receive(:find).and_return book
    end

    it "receives include? for searching current book" do
      expect(wish_list.books).to receive(:include?).with(book)
      post :add_book, book_id: book.id, user_id: user.id
    end

    it "sends fail message when book is already in wish list " do
      allow(wish_list.books).to receive(:include?).and_return true
      post :add_book, book_id: book.id, user_id: user.id
      expect(flash[:alert]).to eq(I18n.t("wish_list.add_fail"))
    end

    it "sends success message when book is not in wish list" do
      allow(wish_list.books).to receive(:include?).and_return false
      post :add_book, book_id: book.id, user_id: user.id
      expect(flash[:notice]).to eq(I18n.t("wish_list.add_success"))
    end
  end

  describe "DELETE #remove_book" do
    before do
      allow(user.wish_list.books).to receive(:find).and_return book
    end

    it "sends success message for removing book form wish list" do
      delete :remove_book, book_id: book.id, user_id: user.id
      expect(flash[:notice]).to eq(I18n.t("wish_list.remove_success"))
    end
  end
end
