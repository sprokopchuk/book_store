require 'rails_helper'
require "cancan/matchers"
RSpec.describe Ability, type: :model do
  describe "abilities of guest user" do
    let(:guest_user) {FactoryGirl.create :guest_user}
    subject {Ability.new(guest_user)}
    context "for ratings" do
      let(:rating_not_approved) {FactoryGirl.create :rating}
      let(:rating_approved) {FactoryGirl.create :rating_approved}
      let(:rating_rejected) {FactoryGirl.create :rating_rejected}
      it {expect(subject).to be_able_to(:read, rating_approved)}
      it {expect(subject).not_to be_able_to(:read, rating_rejected)}
      it {expect(subject).not_to be_able_to(:read, rating_not_approved)}
      it {expect(subject).not_to be_able_to(:create, Rating)}
    end
    context 'for orders' do
      let(:order) {FactoryGirl.create :order, user: guest_user}
      let(:other_order) {FactoryGirl.create :order}
      it {expect(subject).to be_able_to(:update, order)}
      it {expect(subject).not_to be_able_to(:read, order)}
    end
    context "for order item" do
      let(:order) {FactoryGirl.create :order, user: guest_user}
      let(:order_item) {FactoryGirl.create :order_item, order: guest_user.current_order_in_progress}
      let(:other_order_item) {FactoryGirl.create :order_item}
      it {expect(subject).to be_able_to(:create, OrderItem)}
      it {expect(subject).to be_able_to(:destroy, order_item)}
      it {expect(subject).to be_able_to(:destroy_all, order_item)}
    end
  end

  describe "abilities of registered user" do
    let(:authenticated_user) {FactoryGirl.create :user}
    subject {Ability.new(authenticated_user)}
    context "for ratings" do
      let(:rating_not_approved) {FactoryGirl.create :rating}
      let(:rating_approved) {FactoryGirl.create :rating_approved}
      let(:rating_rejected) {FactoryGirl.create :rating_rejected}
      it {expect(subject).to be_able_to(:read, rating_approved)}
      it {expect(subject).to be_able_to(:create, Rating)}
      it {expect(subject).not_to be_able_to(:read, rating_rejected)}
      it {expect(subject).not_to be_able_to(:read, rating_not_approved)}
    end
    context 'for orders' do
      let(:order) {FactoryGirl.create :order, user: authenticated_user}
      let(:other_order) {FactoryGirl.create :order}
      it {expect(subject).to be_able_to(:update, order)}
      it {expect(subject).to be_able_to(:read, order)}
      it {expect(subject).not_to be_able_to(:update, other_order)}
      it {expect(subject).not_to be_able_to(:read, other_order)}
      it "should not be able to complete if order's state is not confirm" do
        expect(subject).not_to be_able_to(:complete, order)
      end
    end
    context "for order items" do
      let(:order) {FactoryGirl.create :order, user: authenticated_user}
      let(:order_item) {FactoryGirl.create :order_item, order: authenticated_user.current_order_in_progress}
      let(:other_order_item) {FactoryGirl.create :order_item}
      it {expect(subject).to be_able_to(:create, OrderItem)}
      it {expect(subject).to be_able_to(:destroy, order_item)}
      it {expect(subject).to be_able_to(:destroy_all, order_item)}
    end

    context "forbidden abilities" do
      it {expect(subject).not_to be_able_to(:manage, Book)}
      it {expect(subject).not_to be_able_to(:manage, Category)}
      it {expect(subject).not_to be_able_to(:manage, Author)}
      it {expect(subject).not_to be_able_to(:manage, User)}
      it {expect(subject).not_to be_able_to(:manage, WishList)}
      it {expect(subject).not_to be_able_to(:manage, Delivery)}
      it {expect(subject).not_to be_able_to(:manage, CreditCard)}
    end
  end
  describe "abilities of admin user" do
    let(:admin) {FactoryGirl.create :admin}
    subject {Ability.new(admin)}
    it {expect(subject).to be_able_to(:manage, WishList)}
    it {expect(subject).to be_able_to(:manage, Rating)}
    it {expect(subject).to be_able_to(:manage, Book)}
    it {expect(subject).to be_able_to(:manage, Category)}
    it {expect(subject).to be_able_to(:manage, Author)}
    it {expect(subject).to be_able_to(:manage, User)}
    it {expect(subject).to be_able_to(:manage, Delivery)}
    context 'for orders' do
      let(:order) {FactoryGirl.create :order, user: admin}
      it {expect(subject).to be_able_to(:read, Order)}
      it {expect(subject).to be_able_to(:update, Order)}
      it {expect(subject).to be_able_to(:create, Order)}
      it {expect(subject).to be_able_to(:destroy, Order)}
      it {expect(subject).to be_able_to(:state, Order)}
      it {expect(subject).to be_able_to(:all_events, Order)}
      it "should not be able to complete if order's state is not confirm" do
        expect(subject).not_to be_able_to(:complete, order)
      end
    end
  end
end
