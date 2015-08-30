require 'rails_helper'
require "cancan/matchers"
RSpec.describe CheckoutForm, type: :model do
  let(:order_in_progress) {FactoryGirl.create :order, user: authenticated_user}
  let(:authenticated_user) {FactoryGirl.create :user}
  let(:country) {FactoryGirl.create :country}
  let(:checkout_form) {CheckoutForm.new current_order: order_in_progress}

  describe "#save_or_update addresses" do

    let(:billing_address_attributes) {FactoryGirl.attributes_for :address, country_id: country.id}
    let(:shipping_address_attributes) {FactoryGirl.attributes_for :address, country_id: country.id}

    before do
      order_in_progress.aasm.current_state = :address
    end
    context "load default billing_address and shipping_address" do
      before do
        FactoryGirl.create :billing_address, country_id: country.id, user_id: authenticated_user.id
        FactoryGirl.create :shipping_address, country_id: country.id, user_id: authenticated_user.id
      end

      it "must be present billing_address" do
        expect(checkout_form.billing_address).not_to be_nil
      end
      it "must be present shipping_address" do
        expect(checkout_form.shipping_address).not_to be_nil
      end

    end
    context "save" do

      it "return true with billing_address and shipping_address" do
        expect(checkout_form.save_or_update billing_address: billing_address_attributes, shipping_address: shipping_address_attributes).to be_truthy
      end

      it "return false with invalid billing_address attributes" do
        billing_address_attributes[:country_id] = nil
        expect(checkout_form.save_or_update billing_address: billing_address_attributes, shipping_address: shipping_address_attributes).to be_falsey
      end
      it "return false with invalid shipping_address attributes" do
        shipping_address_attributes[:country_id] = nil
        expect(checkout_form.save_or_update billing_address: billing_address_attributes, shipping_address: shipping_address_attributes).to be_falsey
      end
      it "return true with option use_billing_as_shipping_address" do
        expect(checkout_form.save_or_update billing_address: billing_address_attributes, use_billing_as_shipping_address = "yes")
      end
    end

    context "update" do

      it "return true with valid billing_address attributes and shipping_address attributes" do
        expect(checkout_form.save_or_update billing_address: billing_address_attributes, shipping_address: shipping_address_attributes).to be_truthy
      end

      it "return false with invalid billing_address attributes" do
        billing_address_attributes[:country_id] = nil
        expect(checkout_form.save_or_update billing_address: billing_address_attributes, shipping_address: shipping_address_attributes).to be_falsey
      end

      it "return false with invalid shipping_address attributes" do
        shipping_address_attributes[:country_id] = nil
        expect(checkout_form.save_or_update billing_address: billing_address_attributes, shipping_address: shipping_address_attributes).to be_falsey
      end

      it "must be updated billing_address of checkout_form" do
        billing_address_attributes[:city] = "Dnepr"
        checkout_form.save_or_update billing_address: billing_address_attributes, shipping_address: shipping_address_attributes
        checkout_form.shipping_address.city
        expect(checkout_form.billing_address.city).to eq("Dnepr")
      end
      it "must be updated shipping_address of checkout_form" do
        shipping_address_attributes[:city] = "Dnepr"
        checkout_form.save_or_update billing_address: billing_address_attributes, shipping_address: shipping_address_attributes
        expect(checkout_form.shipping_address.city).to eq("Dnepr")
      end

    end
  end

  describe "#save_or_update credit_card" do
    let(:credit_card_attrs) {FactoryGirl.attributes_for :credit_card}
    before  do
      order_in_progress.aasm.current_state = :payment
    end
    context "load default credit card" do
      before  do
        FactoryGirl.create :credit_card, user_id: authenticated_user.id
      end
      it "must be peresent credit card" do
        expect(checkout_form.credit_card).not_to be_nil
      end
    end

    context "save" do

      it "return true with valid credit card attributes" do
        expect(checkout_form.save_or_update credit_card: credit_card_attrs).to be_truthy
      end

      it "return false with invalid credit card attributes" do
        credit_card_attrs[:number] = ""
        expect(checkout_form.save_or_update credit_card: credit_card_attrs).to be_falsey
      end

      it "aasigns credit_card for current order" do
        checkout_form.save_or_update credit_card: credit_card_attrs
        expect(checkout_form.current_order.credit_card).not_to be_nil
      end
    end

    context "update" do

      before do
        FactoryGirl.create :credit_card, user_id: authenticated_user.id
      end

      it "return true with valid credit card attributes" do
        expect(checkout_form.save_or_update credit_card: credit_card_attrs).to be_truthy
      end

      it "return false with invalid credit card attributes" do
        credit_card_attrs[:number] = nil
        expect(checkout_form.save_or_update credit_card: credit_card_attrs).to be_falsey
      end

      it "must be updated credit card of checkout_form" do
        credit_card_attrs[:cvv] = 789
        checkout_form.save_or_update credit_card: credit_card_attrs
        expect(checkout_form.credit_card.cvv).to eq(789)
      end
      it "don't change id of credit card for checkout_form" do
        expect{checkout_form.save_or_update credit_card: credit_card_attrs}.not_to change{checkout_form.credit_card.id}
      end
    end
  end

  describe "#save_or_update delivery" do
    let(:deliveries) {FactoryGirl.create_list :delivery, 5}
    let(:delivery_attrs) {{id: deliveries[0].id}}
    before do
      order_in_progress.aasm.current_state = :delivery
    end
    context "load default delivery" do
      before  do
        order_in_progress.update(delivery_id: deliveries[0].id)
      end
      it "must be peresent delivery" do
        expect(checkout_form.delivery).not_to be_nil
      end
    end

    context "update" do

      it "aasigns delivery for current order" do
        checkout_form.save_or_update delivery: delivery_attrs
        expect(checkout_form.current_order.delivery).not_to be_nil
      end

      it "with valid delivery attributes" do
        checkout_form.save_or_update delivery: delivery_attrs
        expect(checkout_form.delivery).not_to be_nil
      end

      it "return true with valid delivery attributes" do
        expect(checkout_form.save_or_update delivery: delivery_attrs).to be_truthy
      end

      it "return false with invalid delivery attributes" do
        delivery_attrs[:id] = ""
        expect(checkout_form.save_or_update delivery: delivery_attrs).to be_falsey
      end

      it "change delivery id for current_order" do
        checkout_form.save_or_update delivery: delivery_attrs
        delivery_attrs[:id] = deliveries[4].id
        expect{checkout_form.save_or_update delivery: delivery_attrs}.to change{checkout_form.current_order.delivery.id}
      end
    end
  end

end
