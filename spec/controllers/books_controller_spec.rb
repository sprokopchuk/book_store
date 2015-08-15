require 'rails_helper'
RSpec.describe BooksController, type: :controller do
  let(:category) {FactoryGirl.create :category}
  let(:book) {FactoryGirl.build_stubbed :book, category_id: category.id}

  describe 'GET #index' do
    it "receives where and return books from category" do
      Book.stub_chain(:where, :page).and_return book
      expect(Book).to receive(:where).with(category_id: book.category.id.to_s)
      get :index, category_id: book.category.id
    end
    it "receives current_category and return current category" do
      expect(Category).to receive(:find).with(book.category.id.to_s)
      get :index, category_id: book.category.id
    end

    it "renders :index template for books from category" do
      get :index, category_id: book.category.id
      expect(response).to render_template :index
    end

    it "renders :index template for all books" do
      get :index
      expect(response).to render_template :index
    end

    it "receives all and return all books" do
      Book.stub_chain(:all, :page).and_return book
      expect(Book).to receive(:all)
      get :index
    end
  end

  describe 'GET #show' do
    before do
      Book.stub(:find).and_return book
    end

    it "receives find and return book" do
      expect(Book).to receive(:find).with(book.id.to_s)
      get :show, id: book.id
    end

    it "assigns @book" do
      get :show, id: book.id
      expect(assigns(:book)).not_to be_nil
    end

    it "renders :show template" do
      get :show, id: book.id
      expect(response).to render_template :show
    end
  end
end
