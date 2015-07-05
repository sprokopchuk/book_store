require 'rails_helper'

RSpec.describe OrderItem, type: :model do
  subject {FactoryGirl.create :order_item}
  it {expect(subject).to validate_presence_of(:price)}
  it {expect(subject).to validate_presence_of(:quantity)}
  it {expect(subject).to validate_numericality_of(:price)}
  it {expect(subject).to validate_numericality_of(:quantity)}
  it {expect(subject).to belong_to(:order)}
  it {expect(subject).to belong_to(:book)}
end
