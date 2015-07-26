require 'rails_helper'

feature 'User management' do

  given!(:customer) {FactoryGirl.create(:customer)}
  given!(:address) {FactoryGirl.create :address}
  background do
    login_as customer, :scope => :user
    visit edit_user_registration_path(customer)
    #fill_in_address(billing_address, "billing", billing_address.country_id)
    #billing_address.customer_billing_address_id = customer.id
    #billing_address.customer_billing_address_id = customer.id
  end

  scenario "find select box for country" do

    find(:select, 'user_billing_address_attributes_country_id').find("option[value='#{billing_address.country_id}']").select_option
    #select billing_address.country_id, :from => "user[billing_address_attributes][country_id]"
    expect(page).to have_select( "user[billing_address_attributes][country_id]")
  end

end
