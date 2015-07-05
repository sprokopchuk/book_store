require 'rails_helper'

describe Country do
  subject {FactoryGirl.create :country }
  it {expect(subject).to validate_presence_of(:name)}
  it {expect(subject).to validate_uniqueness_of(:name)}
  it {expect(subject).to have_many(:addresses)}
end
