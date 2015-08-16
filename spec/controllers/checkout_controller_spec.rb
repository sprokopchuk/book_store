require 'rails_helper'
RSpec.describe Orders::CheckoutController, type: :controller do
  let(:order_in_progress) {FactoryGirl.build_stubbed :order}
  let(:authenticated_user) {FactoryGirl.create :user}
  let(:billing_address) {FactoryGirl.build_stubbed :address, billing_address_id: authenticated_user.id}
  let(:shipping_address) {FactoryGirl.build_stubbed :address, shipping_address_id: authenticated_user.id}
  let(:delivery) {FactoryGirl.create :delivery}

  before(:each) do
    request.env["HTTP_REFERER"] = "localhost:3000/where_i_came_from"
    allow(authenticated_user).to receive(:build_billing_address).and_return billing_address
    allow(authenticated_user).to receive(:build_shipping_address).and_return shipping_address
    allow(authenticated_user).to receive(:current_order_in_progress).and_return order_in_progress
    allow(order_in_progress).to receive_message_chain(:aasm, :set_current_state_with_persistence).and_return true
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_or_guest_user).and_return authenticated_user
  end

  describe "GET #fill_in_address" do
    it "receives set_current_state_with_persistence and set current order's state in fill_in_address" do
      expect(order_in_progress).to receive_message_chain(:aasm, :set_current_state_with_persistence).with(:fill_in_address)
      get :fill_in_address
    end

    it "renders fill_in_address template" do
      get :fill_in_address
      expect(response).to render_template :fill_in_address
    end
  end

  describe "GET #fill_in_delivery" do
    it "receives set_current_state_with_persistence and set current order's state in fill_in_delivery" do
      expect(order_in_progress).to receive_message_chain(:aasm, :set_current_state_with_persistence).with(:fill_in_delivery)
      get :fill_in_delivery
    end

    it "renders fill_in_delivery template" do
      allow(controller).to receive(:redirect_to_checkout).and_return true
      get :fill_in_delivery
      expect(response).to render_template :fill_in_delivery
    end

    it "redirects to fill_in_address if billing_address or shipping_address is nil" do
      get :fill_in_delivery
      expect(response).to redirect_to fill_in_address_checkout_path
    end
  end

  describe "GET #fill_in_payment" do
    it "receives set_current_state_with_persistence and set current order's state in fill_in_payment" do
      expect(order_in_progress).to receive_message_chain(:aasm, :set_current_state_with_persistence).with(:fill_in_payment)
      get :fill_in_payment
    end

    it "renders fill_in_delivery template" do
      allow(controller).to receive(:redirect_to_checkout).and_return true
      get :fill_in_payment
      expect(response).to render_template :fill_in_payment
    end

    it "redirects to fill_in_address if billing_address or shipping_address is nil" do
      get :fill_in_payment
      expect(response).to redirect_to fill_in_address_checkout_path
    end
    xit "redirects to fill_in_delivery if delivery is nil" do
      get :fill_in_payment
      expect(response).to redirect_to fill_in_delivery_checkout_path
    end
  end

  describe "GET #confirm" do

  end

  describe "GET #complete" do

  end

  describe "PUT #update" do

  end
end
