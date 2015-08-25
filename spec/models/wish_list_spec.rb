require 'rails_helper'

RSpec.describe WishList, type: :model do
  subject {FactoryGirl.create :wish_list}
  it {expect(subject).to belong_to(:user)}
  it {expect(subject).to validate_presence_of(:user)}
  it {expect(subject).to have_and_belong_to_many(:books)}
end

