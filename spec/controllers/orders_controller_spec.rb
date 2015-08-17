require 'rails_helper'
RSpec.describe OrdersController, type: :controller do
  let(:order_in_progress) {FactoryGirl.build_stubbed :order, user: authenticated_user}
  let(:other_order) {FactoryGirl.build_stubbed :order}
  let(:order_delivered) {FactoryGirl.build_stubbed :order_delivered, user: authenticated_user}
  let(:authenticated_user) {FactoryGirl.create :user}
  let(:order_item) {FactoryGirl.build_stubbed :order_item}
  let(:order_params) {{"order_items_attributes" => {"0" => {"id" => order_item.id.to_s, "quantity" => order_item.quantity.to_s}}}}

  before(:each) do
    request.env["HTTP_REFERER"] = "localhost:3000/where_i_came_from"
    allow(authenticated_user).to receive(:current_order_in_progress).and_return order_in_progress
    allow(controller).to receive(:current_or_guest_user).and_return authenticated_user
  end
  describe 'GET #index' do
    before do
      allow(authenticated_user).to receive(:orders).and_return [order_in_progress, order_delivered]
      allow(authenticated_user).to receive(:current_order_in_progress).and_return order_in_progress
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
      allow(authenticated_user).to receive_message_chain(:orders, :find).and_return order_delivered
      allow(authenticated_user).to receive(:current_order_in_progress).and_return order_in_progress
      allow(controller).to receive(:current_or_guest_user).and_return authenticated_user
    end

    xit "receives find and return order" do
      expect(authenticated_user).to receive_message_chain(:orders, :find).with(order_delivered.id.to_s)
      get :show, id: order_delivered.id
    end

    it "receives find and generate RecordNotFound when order is not current user's" do
      expect{get :show, id: other_order.id}.to raise_error(ActiveRecord::RecordNotFound)
    end

    xit "assigns @order" do
      get :show, id: order_delivered.id
      expect(assigns(:order)).not_to be_nil
    end

    xit "renders :show template" do
      get :show, id: order_delivered.id
      expect(response).to render_template :show
    end
  end

  describe "GET #edit" do
    it "renders :edit template" do
      get :edit
      expect(response).to render_template :edit
    end
  end

  describe "PUT #update" do
    before do
      allow(order_in_progress).to receive(:update).and_return true
      allow(authenticated_user).to receive(:current_order_in_progress).and_return order_in_progress
      allow(controller).to receive(:current_or_guest_user).and_return authenticated_user
    end

    context "with valid attributes" do
      it "receives update for @current_order" do
        expect(order_in_progress).to receive(:update).with(order_params)
        put :update, shopping_cart: true, order: order_params
      end

      it "sends success notice when params[:shopping_cart] is not empty" do
        put :update, shopping_cart: true, order: order_params
        expect(flash[:notice]).to eq(I18n.t("current_order.add_success"))
      end

      it "redirects to shopping cart when params[:shopping_cart] is not empty" do
        put :update, shopping_cart: true, order: order_params
        expect(response).to redirect_to(:back)
      end

      it "redirects from fill_in_address to fill_in_delivery" do
        allow(order_in_progress).to receive(:next_step_checkout!).and_return true
        allow(order_in_progress).to receive_message_chain(:aasm, :current_state).and_return :fill_in_delivery
        put :update, checkout: true, order: order_params
        expect(response).to redirect_to :action => "fill_in_delivery", :controller => "orders/checkout"
      end

      it "redirects from fill_in_delivery to fill_in_payment" do
        allow(order_in_progress).to receive(:next_step_checkout!).and_return true
        allow(order_in_progress).to receive_message_chain(:aasm, :current_state).and_return :fill_in_payment
        put :update, checkout: true, order: order_params
        expect(response).to redirect_to :action => "fill_in_payment", :controller => "orders/checkout"
      end

      it "redirects from confirm to complete" do
        allow(order_in_progress).to receive(:next_step_checkout!).and_return true
        allow(order_in_progress).to receive_message_chain(:aasm, :current_state).and_return :confirm
        put :update, checkout: true, order: order_params
        expect(response).to redirect_to complete_checkout_path(order_in_progress)
      end
      it "sends success notice when current order in queue" do
        allow(order_in_progress).to receive(:next_step_checkout!).and_return true
        allow(order_in_progress).to receive_message_chain(:aasm, :current_state).and_return :confirm
        put :update, checkout: true, order: order_params
        expect(flash[:notice]).to eq(I18n.t("current_order.in_queue"))
      end
    end

    context "with invalid attributes" do
      it "sends fail message" do
        put :update
        expect(flash[:notice]).to eq(I18n.t("current_order.add_fail"))
      end
      it "redirects to :back when attempt to update is fail" do
        put :update
        expect(response).to redirect_to :back
      end
    end
  end
end
