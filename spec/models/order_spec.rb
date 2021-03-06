require 'rails_helper'

RSpec.describe Order, type: :model do
  subject {FactoryGirl.create :order}
  it {expect(subject).to validate_presence_of(:total_price)}
  it {expect(subject).to validate_presence_of(:state)}
  it {expect(subject).to validate_numericality_of(:total_price)}
  it {expect(subject).to belong_to(:user)}
  it {expect(subject).to belong_to(:credit_card)}
  it {expect(subject).to have_many(:order_items)}
  it {expect(subject).to have_one(:billing_address)}
  it {expect(subject).to have_one(:shipping_address)}

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
    let(:book_ordered) {FactoryGirl.create :order_item}
    let(:other_book) {FactoryGirl.create :order_item}
    it "add book when other book is already ordered" do
      subject.add book_ordered
      expect{subject.add other_book}.to change{subject.order_items.count}.by(1)
    end
    it "add book when it is not yet ordered" do
      expect{subject.add book_ordered}.to change{subject.order_items.count}.by(1)
    end
    it "add book when it is already ordered" do
      subject.add book_ordered
      book_ordered.quantity = 3
      subject.add book_ordered
      expect(subject.order_items.first.quantity).to eq(3)
    end
  end

  context "#real_price" do
    let(:book_ordered) {FactoryGirl.create :order_item}
    let(:other_book) {FactoryGirl.create :order_item, price: 50}
    it "calculate to price for order when add one book" do
      subject.add book_ordered
      expect(subject.real_price).to eq(100.5)
    end
    it "change #total_price" do
      subject.add book_ordered
      expect{subject.real_price}.to change{subject.total_price}.from(0).to(100.5)
    end
  end
end
