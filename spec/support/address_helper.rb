module AddressHelper
  def fill_in_address(address, type, country = false)
    fill_in "user[#{type}_address_attributes][address]", with: address.address
    fill_in "user[#{type}_address_attributes][city]", with: address.city
    find(:select, "user_#{type}_address_attributes_country_id").find("option[value='#{address.send(:country_id)}']").select_option unless country
    fill_in "user[#{type}_address_attributes][zipcode]", with: address.zipcode
    fill_in "user[#{type}_address_attributes][phone]", with: address.phone
  end

  def check_fields_address(address, type)
    expect(page).to have_field("user[#{type}_address_attributes][address]", with: address.address)
    expect(page).to have_field("user[#{type}_address_attributes][city]", with: address.city)
    expect(page).to have_select("user[#{type}_address_attributes][country_id]", text: address.country.name)
    expect(page).to have_field("user[#{type}_address_attributes][zipcode]", with: address.zipcode)
    expect(page).to have_field("user[#{type}_address_attributes][phone]", with: address.phone)
  end
end
