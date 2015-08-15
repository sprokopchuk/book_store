require 'rails_helper'
RSpec.describe OrdersController, type: :controller do
  let(:order_in_progress) {FactoryGirl.build_stubbed :order}
  let(:order_delivered) {FactoryGirl.build_stubbed :order_delivered}
  let(:book) {FactoryGirl.create :book}
  let(:authenticated_user) {FactoryGirl.create :user}
  let(:order_params) {FactoryGirl.attributes_for(:order).stringify_keys}

  before(:each) do
    request.env["HTTP_REFERER"] = "localhost:3000/where_i_came_from"
  end
  describe 'GET #index' do
    before do
      allow(authenticated_user).to receive(:current_order_in_progress).and_return order_in_progress
      allow(authenticated_user).to receive(:orders).and_return [order_in_progress, order_delivered]
      allow(controller).to receive(:current_or_guest_user).and_return authenticated_user
    end
    it "receives orders and return all orders" do
      expect(authenticated_user).to receive(:orders).and_return [order_in_progress, order_delivered]
      get :index
    end

    it "renders :index template" do
      get :index
      expect(response).to render_template :index
    end
  end

  describe 'GET #show' do
    before do
      allow(authenticated_user).to receive(:current_order_in_progress).and_return order_in_progress
      allow(Order).to receive(:where).and_return order_delivered
      allow(controller).to receive(:current_or_guest_user).and_return authenticated_user
    end

    it "receives find and return order" do
      expect(Order).to receive(:where).with(id: order_delivered.id.to_s, user_id: authenticated_user.id)
      get :show, id: order_delivered.id
    end

    it "assigns @order" do
      get :show, id: order_delivered.id
      expect(assigns(:order)).not_to be_nil
    end

    it "renders :show template" do
      get :show, id: order_delivered.id
      expect(response).to render_template :show
    end
  end

  describe "GET #edit" do

  end

  describe "PUT #update" do

  end
end
