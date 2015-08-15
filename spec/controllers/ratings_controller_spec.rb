require 'rails_helper'
RSpec.describe RatingsController, type: :controller do
  let(:book) {FactoryGirl.create :book}
  let(:authenticated_user) {FactoryGirl.create :user}
  let(:rating_params) {FactoryGirl.attributes_for(:rating, book_id: book.id.to_s).stringify_keys}
  let(:rating) {FactoryGirl.build_stubbed :rating}
  before(:each) do
    request.env["HTTP_REFERER"] = "localhost:3000/where_i_came_from"
  end
  describe 'POST #create' do
    context "with valid attributes" do
      before do
        rating.stub(:save).and_return(true)
        authenticated_user.stub_chain(:ratings, :build).and_return rating
        controller.stub(:current_or_guest_user).and_return authenticated_user
      end

      it "assigns @rating" do
        post :create, rating: rating_params
        expect(assigns(:rating)).not_to be_nil
      end

      it "receives build for @rating" do
        expect(authenticated_user.ratings).to receive(:build).with(rating_params)
        post :create, rating: rating_params
      end
      it "sends success notice" do
        post :create, rating: rating_params
        expect(flash[:notice]).to eq I18n.t("ratings.add_success")
      end

      it "redirects to back" do
        post :create, rating: rating_params
        expect(response).to redirect_to :back
      end
    end
    context "with invalid attributes" do
      before do
        rating.stub(:save).and_return false
        authenticated_user.stub_chain(:ratings, :build).and_return rating
        controller.stub(:current_or_guest_user).and_return authenticated_user
      end

      it "sends fail notice" do
        post :create, rating: rating_params
        expect(flash[:notice]).to eq I18n.t("ratings.add_fail")
      end

      it "redirects to back" do
        post :create, rating: rating_params
        expect(response).to redirect_to :back
      end
    end
    context "with forbidden attributes" do
      before do
        rating.stub(:save).and_return true
        authenticated_user.stub_chain(:ratings, :build).and_return rating
        controller.stub(:current_or_guest_user).and_return authenticated_user
      end
      it "generates ParameterMissing error without rating params" do
        expect{post :create}.to raise_error(ActionController::ParameterMissing)
      end
      it "filters forbidden params" do
        expect(authenticated_user.ratings).to receive(:build).with(rating_params)
        post :create, rating: rating_params.merge(user_id: 1)
      end
    end
  end
end
