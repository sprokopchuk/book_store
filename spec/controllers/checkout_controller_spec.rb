require 'rails_helper'
RSpec.describe Orders::CheckoutController, type: :controller do
  let(:order_in_progress) {FactoryGirl.build_stubbed :order}
  let(:other_order) {FactoryGirl.build_stubbed :order}
  let(:authenticated_user) {FactoryGirl.create :user}
  let(:billing_address) {FactoryGirl.build_stubbed :address, billing_address: true, user_id: authenticated_user.id}
  let(:shipping_address) {FactoryGirl.build_stubbed :address, shipping_address: true, user_id: authenticated_user.id}
  let(:delivery) {FactoryGirl.create :delivery}
  let(:checkout_form) {double('CheckoutForm')}
  before(:each) do
    request.env["HTTP_REFERER"] = "localhost:3000/where_i_came_from"
    allow(CheckoutForm).to receive(:new).and_return checkout_form
    allow(checkout_form).to receive(:set_current_state_with_persistence).and_return true
    allow(controller).to receive(:authenticate_user!).and_return(true)
    allow(controller).to receive(:current_user).and_return authenticated_user
    allow(authenticated_user).to receive(:current_order_in_progress).and_return order_in_progress
  end

  describe "GET #address" do

    it "renders address template" do
      allow(controller).to receive(:set_data).and_return true
      get :address
      expect(response).to render_template :address
    end

  end

  describe "GET #delivery" do

    it "renders delivery template" do
      allow(controller).to receive(:set_data).and_return true
      get :delivery
      expect(response).to render_template :delivery
    end

    it "redirects to address if billing_address or shipping_address is nil" do
      allow(checkout_form).to receive(:ready_to_checkout?).and_return true
      allow(checkout_form).to receive(:previous_step).and_return :address
      allow(checkout_form).to receive(:to_previous_step?).and_return true
      get :delivery
      expect(response).to redirect_to address_checkout_path
    end
  end

  describe "GET #payment" do

    before do
      allow(checkout_form).to receive(:ready_to_checkout?).and_return true
      allow(checkout_form).to receive(:to_previous_step?).and_return true
    end
    it "renders :payment template" do
      allow(controller).to receive(:set_data).and_return true
      get :payment
      expect(response).to render_template :payment
    end

    it "redirects to address if billing_address or shipping_address is nil" do
      allow(checkout_form).to receive(:previous_step).and_return :address
      get :payment
      expect(response).to redirect_to address_checkout_path
    end
    it "redirects to delivery if delivery is nil" do
      allow(checkout_form).to receive(:previous_step).and_return :delivery
      get :payment
      expect(response).to redirect_to delivery_checkout_path
    end
  end

  describe "GET #confirm" do

    before do
      allow(checkout_form).to receive(:ready_to_checkout?).and_return true
      allow(checkout_form).to receive(:to_previous_step?).and_return true
    end

    it "renders :confirm template" do
      allow(controller).to receive(:set_data).and_return true
      get :confirm
      expect(response).to render_template :confirm
    end

    it "redirects to address if billing_address or shipping_address is nil" do
      allow(checkout_form).to receive(:previous_step).and_return :address
      get :confirm
      expect(response).to redirect_to address_checkout_path
    end
    it "redirects to delivery if delivery is nil" do
      allow(checkout_form).to receive(:previous_step).and_return :delivery
      get :confirm
      expect(response).to redirect_to delivery_checkout_path
    end

    it "redirects to payment if credit card for order is nil" do
      allow(checkout_form).to receive(:previous_step).and_return :payment
      get :confirm
      expect(response).to redirect_to payment_checkout_path
    end
  end

  describe "GET #complete" do

    let(:ability) {Object.new}

    before do
      ability.extend(CanCan::Ability)
      allow(controller).to receive(:current_ability).and_return(ability)
      ability.can :manage, :all
      sign_in authenticated_user
    end

    context "cancan doesn't allow user :complete if order is not in state confirm" do
      before do
        allow(Order).to receive(:find).and_return order_in_progress
        ability.cannot :complete, order_in_progress
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

  describe "PUT #update" do
    let(:checkout_form_params) {{billing_address: FactoryGirl.attributes_for(:address)}}
    before do
      allow(checkout_form).to receive(:current_state).and_return :delivery
    end

    context "with valid attributes" do
      it "receives save_or_update for @checkout_form" do
        expect(checkout_form).to receive(:save_or_update).with(checkout_form_params)
        put :update, checkout_form: checkout_form_params
      end

      it "redirects to next step checkout" do
        allow(checkout_form).to receive(:save_or_update).and_return true
        allow(checkout_form).to receive(:next_step_checkout!).and_return true
        put :update, checkout_form: checkout_form_params
        expect(response).to redirect_to delivery_checkout_path
      end
    end

    context "with invalid attributes" do

      it "render current state template" do
        allow(checkout_form).to receive(:save_or_update).and_return false
        put :update, checkout_form: checkout_form_params
        expect(response).to render_template :delivery
      end
    end

  end
end
