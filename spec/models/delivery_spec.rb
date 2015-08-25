require 'rails_helper'

RSpec.describe Delivery, type: :model do
  subject {FactoryGirl.create :delivery}
  it {expect(subject).to validate_presence_of(:price)}
  it {expect(subject).to validate_presence_of(:name)}
  it {expect(subject).to have_many(:orders)}
end
