require 'rails_helper'
RSpec.describe Orders::CheckoutController, type: :controller do
  let(:order_in_progress) {FactoryGirl.build_stubbed :order, credit_card: nil}
  let(:other_order) {FactoryGirl.build_stubbed :order}
  let(:authenticated_user) {FactoryGirl.create :user}
  let(:billing_address) {FactoryGirl.build_stubbed :address, billing_address: true, user_id: authenticated_user.id}
  let(:shipping_address) {FactoryGirl.build_stubbed :address, shipping_address: true, user_id: authenticated_user.id}
  let(:delivery) {FactoryGirl.create :delivery}

  before(:each) do
    request.env["HTTP_REFERER"] = "localhost:3000/where_i_came_from"
    allow(authenticated_user).to receive(:current_order_in_progress).and_return order_in_progress
    allow(order_in_progress).to receive_message_chain(:aasm, :set_current_state_with_persistence).and_return true
    allow(order_in_progress).to receive(:ready_to_checkout?).and_return true
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return authenticated_user
  end

  describe "GET #address" do
    it "receives set_current_state_with_persistence and set current order's state in :address" do
      expect(order_in_progress).to receive_message_chain(:aasm, :set_current_state_with_persistence).with(:address)
      get :address
    end

    it "renders address template" do
      get :address
      expect(response).to render_template :address
    end

  end

  describe "GET #delivery" do
    it "receives set_current_state_with_persistence and set current order's state in delivery" do
      allow(controller).to receive(:redirect_to_checkout).and_return true
      expect(order_in_progress).to receive_message_chain(:aasm, :set_current_state_with_persistence).with(:delivery)
      get :delivery
    end

    it "renders delivery template" do
      allow(controller).to receive(:redirect_to_checkout).and_return true
      get :delivery
      expect(response).to render_template :delivery
    end

    it "redirects to address if billing_address or shipping_address is nil" do
      get :delivery
      expect(response).to redirect_to address_checkout_path
    end
  end

  describe "GET #payment" do
    it "receives set_current_state_with_persistence and set current order's state in payment" do
      allow(controller).to receive(:redirect_to_checkout).and_return true
      expect(order_in_progress).to receive_message_chain(:aasm, :set_current_state_with_persistence).with(:payment)
      get :payment
    end

    it "renders :payment template" do
      allow(controller).to receive(:redirect_to_checkout).and_return true
      get :payment
      expect(response).to render_template :payment
    end

    it "redirects to address if billing_address or shipping_address is nil" do
      get :payment
      expect(response).to redirect_to address_checkout_path
    end
    it "redirects to delivery if delivery is nil" do
      allow(order_in_progress).to receive(:billing_address).and_return billing_address
      allow(order_in_progress).to receive(:shipping_address).and_return shipping_address
      get :payment
      expect(response).to redirect_to delivery_checkout_path
    end
  end

  describe "GET #confirm" do
    it "receives set_current_state_with_persistence and set current order's state in confirm" do
      allow(controller).to receive(:redirect_to_checkout).and_return true
      expect(order_in_progress).to receive_message_chain(:aasm, :set_current_state_with_persistence).with(:confirm)
      get :confirm
    end

    it "renders :confirm template" do
      allow(controller).to receive(:redirect_to_checkout).and_return true
      get :confirm
      expect(response).to render_template :confirm
    end

    it "redirects to address if billing_address or shipping_address is nil" do
      get :confirm
      expect(response).to redirect_to address_checkout_path
    end
    it "redirects to delivery if delivery is nil" do
      allow(order_in_progress).to receive(:billing_address).and_return billing_address
      allow(order_in_progress).to receive(:shipping_address).and_return shipping_address
      get :confirm
      expect(response).to redirect_to delivery_checkout_path
    end

    it "redirects to payment if credit card for order is nil" do
      allow(order_in_progress).to receive(:billing_address).and_return billing_address
      allow(order_in_progress).to receive(:shipping_address).and_return shipping_address
      allow(order_in_progress).to receive(:delivery).and_return delivery
      get :confirm
      expect(response).to redirect_to payment_checkout_path
    end
  end

  describe "GET #complete" do

    let(:ability) {Object.new}

    before do
      ability.extend(CanCan::Ability)
      allow(controller).to receive(:current_ability).and_return(ability)
      ability.cannot :manage, :all
      sign_in authenticated_user
    end

    context "cancan doesn't allow user :complete if order is not in state in_queue" do
      before do
        allow(Order).to receive(:find).and_return order_in_progress
      end
      it "redirects to root path" do
        get :complete, id: order_in_progress.id
        expect(response).to redirect_to root_path
      end

      it "sends flash alert" do
        get :complete, id: order_in_progress.id
        expect(flash[:alert]).to eq("You are not authorized to access this page.")
      end
    end



  end

end
