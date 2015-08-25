require 'rails_helper'
require "cancan/matchers"
RSpec.describe CheckoutForm, type: :model do
  let(:order_in_progress) {FactoryGirl.create :order, user: authenticated_user}
  let(:authenticated_user) {FactoryGirl.create :user}
  let(:country) {FactoryGirl.create :country}
  let(:billing_address) {FactoryGirl.create :address, country_id: country.id, billing_address: true, user_id: authenticated_user.id}
  let(:shipping_address) {FactoryGirl.create :address, country_id: country.id, shipping_address: true, user_id: authenticated_user.id}
  let(:billing_address_attributes) {FactoryGirl.attributes_for :address, country_id: country.id}
  let(:shipping_address_attributes) {FactoryGirl.attributes_for :address, country_id: country.id}
  let(:checkout_form) {CheckoutForm.new current_order: order_in_progress}
  describe "#save_or_update addresses" do

    context "checkout_form load billing_address and shipping_address after initialize" do
      before do
        order_in_progress.aasm.current_state = :fill_in_address
        billing_address
        shipping_address
      end

      it "must be present billing_address" do
        expect(checkout_form.billing_address).not_to be_nil
      end
      it "must be present shipping_address" do
        expect(checkout_form.shipping_address).not_to be_nil
      end

    end
    context "save" do
      before do
        order_in_progress.aasm.current_state = :address
      end
      it "with billing_address and shipping_address" do
        checkout_form.save_or_update billing_address: billing_address_attributes, shipping_address: shipping_address_attributes
        expect(checkout_form.billing_address).not_to be_nil
        expect(checkout_form.shipping_address).not_to be_nil
      end

      it "with billing_address and shipping_address return true" do
        expect(checkout_form.save_or_update billing_address: billing_address_attributes, shipping_address: shipping_address_attributes).to be_truthy
      end

      it "with invalid billing_address attributes return false" do
        billing_address_attributes[:country_id] = nil
        expect(checkout_form.save_or_update billing_address: billing_address_attributes, shipping_address: shipping_address_attributes).to be_falsey
        expect(checkout_form.billing_address).to be_nil
      end
      it "with invalid shipping_address attributes return false" do
        shipping_address_attributes[:country_id] = nil
        expect(checkout_form.save_or_update billing_address: billing_address_attributes, shipping_address: shipping_address_attributes).to be_falsey
        expect(checkout_form.shipping_address).to be_nil
      end
      it "with option use_shipping_as_billing_address" do
        checkout_form.save_or_update billing_address: billing_address_attributes, shipping_address: shipping_address_attributes, use_shipping_as_billing_address: true
        expect(checkout_form.billing_address).not_to be_nil
        expect(checkout_form.shipping_address).not_to be_nil
      end
    end

    context "update" do
      before do
        order_in_progress.aasm.current_state = :address
        checkout_form.save_or_update billing_address: billing_address_attributes, shipping_address: shipping_address_attributes
      end

      it "with valid billing_address attributes and shipping_address attributes" do
        checkout_form.save_or_update billing_address: billing_address_attributes, shipping_address: shipping_address_attributes
        expect(checkout_form.billing_address).not_to be_nil
        expect(checkout_form.shipping_address).not_to be_nil
      end

      it "with valid billing_address attributes and shipping_address attributes return true" do
        expect(checkout_form.save_or_update billing_address: billing_address_attributes, shipping_address: shipping_address_attributes).to be_truthy
      end

      it "with invalid billing_address attributes return falsey" do
        billing_address_attributes[:country_id] = nil
        expect(checkout_form.save_or_update billing_address: billing_address_attributes, shipping_address: shipping_address_attributes).to be_falsey
      end

      it "with invalid shipping_address attributes return falsey" do
        shipping_address_attributes[:country_id] = nil
        expect(checkout_form.save_or_update billing_address: billing_address_attributes, shipping_address: shipping_address_attributes).to be_falsey
      end

      it "billing_address of checkout_form must be updated" do
        billing_address_attributes[:city] = "Dnepr"
        checkout_form.save_or_update billing_address: billing_address_attributes, shipping_address: shipping_address_attributes
        expect(checkout_form.billing_address.city).to eq("Dnepr")
      end
      it "shipping_address of checkout_form must be updated" do
        shipping_address_attributes[:city] = "Dnepr"
        checkout_form.save_or_update billing_address: billing_address_attributes, shipping_address: shipping_address_attributes
        expect(checkout_form.shipping_address.city).to eq("Dnepr")
      end

    end
  end
end
