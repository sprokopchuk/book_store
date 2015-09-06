require 'rails_helper'
RSpec.describe OrdersController, type: :controller do
  let(:order_in_progress) {FactoryGirl.build_stubbed :order, user: authenticated_user}
  let(:order_delivered) {FactoryGirl.build_stubbed :order_delivered, user: authenticated_user}
  let(:authenticated_user) {FactoryGirl.create :user}
  let(:ability) { Ability.new(authenticated_user) }
  before(:each) do
    request.env["devise.mapping"] = Devise.mappings[:authenticated_user]
    request.env["HTTP_REFERER"] = "localhost:3000/where_i_came_from"
    allow(authenticated_user).to receive(:current_order_in_progress).and_return order_in_progress
    allow(controller).to receive(:current_or_guest_user).and_return authenticated_user
    allow(controller).to receive(:current_ability).and_return(ability)
    ability.can :manage, :all
  end
  describe 'GET #index' do
    before do
      allow(Order).to receive(:accessible_by).and_return [order_in_progress, order_delivered]
    end
    it "receives orders and return all orders" do
      expect(Order).to receive(:accessible_by).and_return [order_in_progress, order_delivered]
      get :index
    end

    it "renders :index template" do
      get :index
      expect(response).to render_template :index
    end

    context "without ability to index" do
      before do
        ability.cannot :read, Order
      end

      it "redirects to root path" do
        get :index
        expect(response).to redirect_to root_path
      end
    end
  end

  describe 'GET #show' do
    before do
      allow(Order).to receive(:find).and_return order_delivered
    end

    it "receives find and return order" do
      expect(Order).to receive(:find).with(order_delivered.id.to_s)
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
    context "without ability to show" do
      before do
        ability.cannot :read, Order
      end

      it "redirects to root path" do
        get :show, id: order_delivered.id
        expect(response).to redirect_to root_path
      end
    end
  end

end
