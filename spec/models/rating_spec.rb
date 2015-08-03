require 'rails_helper'

RSpec.describe Rating, type: :model do
  subject {FactoryGirl.create :rating}
  it {expect(subject).to validate_presence_of(:review)}
  it {expect(subject).to validate_presence_of(:rate)}
  it {expect(subject).to validate_inclusion_of(:rate).in_range(1..10)}
  it {expect(subject).to belong_to(:book)}
  it {expect(subject).to belong_to(:user)}
end
