require 'rails_helper'

RSpec.describe Order, type: :model do
  subject {FactoryGirl.create :order}
  it {expect(subject).to validate_presence_of(:total_price)}
  it {expect(subject).to validate_presence_of(:completed_date)}
  it {expect(subject).to validate_presence_of(:state)}
  it {expect(subject).to validate_numericality_of(:total_price)}
  it {expect(subject).to belong_to(:customer)}
  it {expect(subject).to belong_to(:credit_card)}
  it {expect(subject).to have_many(:order_items)}
  it {expect(subject).to belong_to(:billing_address).with_foreign_key("billing_address_id")}
  it {expect(subject).to belong_to(:shipping_address).with_foreign_key("shipping_address_id")}
  it {expect(subject).to validate_inclusion_of(:state).in_array(Order::STATES)}

  context "before save order" do
    let(:book_ordered) {FactoryGirl.create :book}
    it "calculate real price" do
      subject.add book_ordered
      expect{subject.save}.to change{subject.total_price}.from(0.0).to(100.5)
    end
  end

  context ".in_progress" do
    let(:orders_in_progress) {FactoryGirl.create_list(:order, 3)}
    let(:orders_delivered) {FactoryGirl.create_list(:order_delivered, 3)}
    it "returns list of orders in state in progress" do
      expect(Order.in_progress).to match_array(orders_in_progress)
    end
    it "doesn't return list of orders in state shipped" do
      expect(Order.in_progress).not_to match_array(orders_delivered)
    end
  end

  context "#add" do
    let(:book_ordered) {FactoryGirl.create :book}
    let(:other_book) {FactoryGirl.create :book}
    it "add book when other book is already ordered" do
      subject.add book_ordered
      expect{subject.add other_book}.to change{subject.order_items.count}.by(1)
    end
    it "add book when it is not yet ordered" do
      expect{subject.add book_ordered}.to change{subject.order_items.count}.by(1)
    end
    it "add book when it is already ordered" do
      subject.add book_ordered, 3
      expect(subject.order_items.first.quantity).to eq(3)
    end
  end

  context "#real_price" do
    let(:book_ordered) {FactoryGirl.create :book}
    let(:other_book) {FactoryGirl.create :book, price: 50}
    it "calculate to price for order when add one book" do
      subject.add book_ordered
      expect(subject.real_price).to eq(100.5)
    end
    it "change #total_price" do
      subject.add book_ordered
      expect{subject.real_price}.to change{subject.total_price}.from(0).to(100.5)
    end
    it "calculate to price for order when add two same books" do
      subject.add book_ordered, 2
      expect(subject.real_price).to eq(201)
    end
    it "calculate to price for order when add two different books" do
      subject.add book_ordered
      subject.add other_book
      expect(subject.real_price).to eq(150.5)
    end
  end
end
