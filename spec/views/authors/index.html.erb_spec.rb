require 'rails_helper'

RSpec.describe "authors/index", type: :view do
  before(:each) do
    assign(:authors, [
      Author.create!(),
      Author.create!()
    ])
  end

  it "renders a list of authors" do
    render
  end
end
