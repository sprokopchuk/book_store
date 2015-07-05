require 'rails_helper'

RSpec.describe CreditCard, type: :model do
  subject {FactoryGirl.create :credit_card}
  it {expect(subject).to validate_presence_of(:number)}
  it {expect(subject).to validate_presence_of(:cvv)}
  it {expect(subject).to validate_presence_of(:exp_month)}
  it {expect(subject).to validate_presence_of(:exp_year)}
  it {expect(subject).to validate_presence_of(:first_name)}
  it {expect(subject).to validate_presence_of(:last_name)}
  it {expect(subject).to validate_inclusion_of(:exp_month).in_range(1..12)}
  it {expect(subject).to validate_numericality_of(:cvv)}
  it {expect(subject).to validate_length_of(:number)}
  it {expect(subject).to have_many(:orders)}
  it {expect(subject).to belong_to(:customer)}
end
