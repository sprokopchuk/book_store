require 'rails_helper'
RSpec.describe WishListsController, type: :controller do
  let(:book) {FactoryGirl.create :book}
  let(:user) {FactoryGirl.build_stubbed :user}
  let(:wish_list) {FactoryGirl.build_stubbed :wish_list, user: user}
  let(:ability) { Ability.new(user) }

  before do
    request.env["HTTP_REFERER"] = "localhost:3000/where_i_came_from"
    allow(controller).to receive(:current_or_guest_user).and_return user
    allow(user).to receive(:wish_list).and_return wish_list
    allow(controller).to receive(:authenticate_user!).and_return true
    allow(controller).to receive(:current_ability).and_return(ability)
    ability.can :manage, :all
  end

  describe 'GET #show' do

    it "renders :show template" do
      get :show, user_id: user.id
      expect(response).to render_template :show
    end

    context "without ability to show" do
      before do
        ability.cannot :read, WishList
      end

      it "redirects to root path" do
        get :show, user_id: user.id
        expect(response).to redirect_to root_path
      end
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

    context "without ability to add_book" do
      before do
        ability.cannot :add_book, WishList
      end

      it "redirects to root path" do
        post :add_book, book_id: book.id, user_id: user.id
        expect(response).to redirect_to root_path
      end
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

    context "without ability to remove_book" do
      before do
        ability.cannot :remove_book, WishList
      end

      it "redirects to root path" do
        delete :remove_book, book_id: book.id, user_id: user.id
        expect(response).to redirect_to root_path
      end
    end

  end
end
