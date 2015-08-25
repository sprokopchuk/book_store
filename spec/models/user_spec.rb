require 'rails_helper'

RSpec.describe User, type: :model do
  subject {FactoryGirl.create :user}
  it {expect(subject).to validate_presence_of(:first_name)}
  it {expect(subject).to validate_presence_of(:last_name)}
  it {expect(subject).to have_many(:orders)}
  it {expect(subject).to have_many(:ratings)}
  it {expect(subject).to have_one(:credit_card)}

  context "#current_order_in_progress" do
    let(:book_ordered) {FactoryGirl.create :order_item}
    it "return a current order in progress" do
      expect(subject.current_order_in_progress.class).to be(Order)
    end

    it "able add book through the current order" do
      subject.current_order_in_progress.add book_ordered
      expect(subject.current_order_in_progress.order_items).to have(1).items
    end
  end
end
