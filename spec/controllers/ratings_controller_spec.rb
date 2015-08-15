require 'rails_helper'
RSpec.describe RatingsController, type: :controller do
  let(:rating_params) {FactoryGirl.attributes_for(:rating).stringify_keys}
  let(:guest_user) {FactoryGirl.create :guest_user}
  let(:rating) {FactoryGirl.build_stubbed :rating}
  describe 'POST #create' do
    context "without ability to create" do
      before do
        guest_user.stub_chain(:ratings, :build).and_return true
        controller.stub(:current_or_guest_user).and_return guest_user
        post :create, id: rating.id, rating: rating_params
      end
      it "redirects to root page" do
        puts response.body
        expect(response).to redirect_to(root_path)
      end
      it "sends notice" do
        expect(flash[:notice]).to eq("You are not authorized to access this page.")
      end
    end
    context "with valid attributes" do
    end
    context "wit invalid attributes" do
    end
    context "with forbidden attributes" do
    end
  end
end
