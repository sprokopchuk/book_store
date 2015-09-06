require 'rails_helper'
RSpec.describe RatingsController, type: :controller do
  let(:book) {FactoryGirl.create :book}
  let(:authenticated_user) {FactoryGirl.create :user}
  let(:rating_params) {FactoryGirl.attributes_for(:rating, book_id: book.id.to_s).stringify_keys}
  let(:rating) {FactoryGirl.build_stubbed :rating}
  let(:ability) { Ability.new(authenticated_user) }
  before(:each) do
    request.env["HTTP_REFERER"] = "localhost:3000/where_i_came_from"
    allow(controller).to receive(:current_or_guest_user).and_return authenticated_user
    allow(controller).to receive(:current_ability).and_return(ability)
    allow(Rating).to receive(:new).and_return rating
    ability.can :manage, :all
  end
  describe 'POST #create' do
    before do
      allow(rating).to receive(:user_id).and_return authenticated_user.id
    end
    context "with valid attributes" do
      before do
        allow(rating).to receive(:save).and_return(true)
      end

      it "assigns @rating" do
        post :create, rating: rating_params
        expect(assigns(:rating)).not_to be_nil
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
        allow(rating).to receive(:save).and_return false
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
        allow(rating).to receive(:save).and_return true
      end
      it "generates ParameterMissing error without rating params" do
        expect{post :create}.to raise_error(ActionController::ParameterMissing)
      end
      it "filters forbidden params" do
        post :create, rating: rating_params.merge(user_id: 1)
      end
    end

    context "without ability to create" do
      before do
        ability.cannot :create, Rating
      end

      it "redirects to root path" do
        post :create, rating: rating_params
        expect(response).to redirect_to root_path
      end
    end

  end

end
