require 'rails_helper'

RSpec.describe "books/index", type: :view do
  before(:each) do
    assign(:books, [
      Book.create!(),
      Book.create!()
    ])
  end

  it "renders a list of books" do
    render
  end
end
