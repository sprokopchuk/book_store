module AddressHelper
  def fill_in_address(address, type, object, country = false)
    name_address = "address"
    name_address = "address_attributes" if object == "user"
    fill_in "#{object}[#{type}_#{name_address}][address]", with: address[:address]
    fill_in "#{object}[#{type}_#{name_address}][city]", with: address[:city]
    find(:select, "#{object}_#{type}_#{name_address}_country_id").find("option[value='#{address[:country_id]}']").select_option unless country
    fill_in "#{object}[#{type}_#{name_address}][zipcode]", with: address[:zipcode]
    fill_in "#{object}[#{type}_#{name_address}][phone]", with: address[:phone]
  end

  def check_fields_address(address, type, object)
    name_address = "address"
    name_address = "address_attributes" if object == "user"
    expect(page).to have_field("#{object}[#{type}_#{name_address}][address]", with: address.address)
    expect(page).to have_field("#{object}[#{type}_#{name_address}][city]", with: address.city)
    expect(page).to have_select("#{object}[#{type}_#{name_address}][country_id]", text: address.country.name)
    expect(page).to have_field("#{object}[#{type}_#{name_address}][zipcode]", with: address.zipcode)
    expect(page).to have_field("#{object}[#{type}_#{name_address}][phone]", with: address.phone)
  end
end
