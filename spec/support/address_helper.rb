module AddressHelper
  def fill_in_address(address, type, country = false)
    fill_in "checkout_form[#{type}_address][address]", with: address[:address]
    fill_in "checkout_form[#{type}_address][city]", with: address[:city]
    find(:select, "checkout_form_#{type}_address_country_id").find("option[value='#{address[:country_id]}']").select_option unless country
    fill_in "checkout_form[#{type}_address][zipcode]", with: address[:zipcode]
    fill_in "checkout_form[#{type}_address][phone]", with: address[:phone]
  end

  def check_fields_address(address, type)
    expect(page).to have_field("checkout_form[#{type}_address][address]", with: address.address)
    expect(page).to have_field("checkout_form[#{type}_address][city]", with: address.city)
    expect(page).to have_select("checkout_form[#{type}_address][country_id]", text: address.country.name)
    expect(page).to have_field("checkout_form[#{type}_address][zipcode]", with: address.zipcode)
    expect(page).to have_field("checkout_form[#{type}_address][phone]", with: address.phone)
  end
end
