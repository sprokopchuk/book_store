require 'rails_helper'

feature 'User management' do

  background  do
    visit root_path
  end
  given!(:customer) {FactoryGirl.create(:customer)}
  given!(:billing_address) {FactoryGirl.create :address}
  given!(:shipping_address) {FactoryGirl.create :address}

  feature 'register a new user' do

    scenario {expect(page).to have_link(I18n.t("settings.register"), href: new_user_registration_path)}

    feature 'should have form for register' do
      background do
        click_link I18n.t("settings.register")
      end
      scenario {expect(page).to have_field("user[email]") }
      scenario {expect(page).to have_field("user[password]")}
      scenario {expect(page).to have_field("user[password_confirmation]")}
      scenario {expect(page).to have_button(I18n.t("settings.register"))}
      scenario {expect(page).to have_link(I18n.t("sessions.log_in"), href: new_user_session_path)}
      scenario {expect(page).to have_link("", href: user_omniauth_authorize_path(:facebook))}
    end

    scenario 'with blank email' do
      click_link I18n.t("settings.register")
      within "#new_user" do
        fill_in "user[password]", with: "password"
        fill_in "user[password_confirmation]", with: "password"
        click_button(I18n.t("settings.register"))
      end
      expect(page).to have_content("Email can't be blank")
    end

    scenario "when email is already registered" do
      click_link I18n.t("settings.register")
       within "#new_user" do
        fill_in "user[email]", with: customer.email
        fill_in "user[password]", with: customer.password
        fill_in "user[password_confirmation]", with: customer.password
        click_button(I18n.t("settings.register"))
      end
      expect(page).to have_content("Email has already been taken")
    end

    scenario 'with blank password' do
      click_link I18n.t("settings.register")
      within "#new_user" do
        fill_in "user[email]", with: "email@email.com"
        fill_in "user[password_confirmation]", with: "password"
        click_button(I18n.t("settings.register"))
      end
      expect(page).to have_content("Password can't be blank")
      expect(page).to have_content("Password confirmation doesn't match Password")
    end

    scenario 'with a password and password confirmation less then 8 characters' do
      click_link I18n.t("settings.register")
      within "#new_user" do
        fill_in "user[password]", with: "123456"
        fill_in "user[password_confirmation]", with: "123456"
        click_button(I18n.t("settings.register"))
      end
      expect(page).to have_content("Password is too short (minimum is 8 characters)")
    end

    scenario "when a password and password confirmation doesn't match" do
      click_link I18n.t("settings.register")
      within "#new_user" do
        fill_in "user[email]", with: "email@email.com"
        fill_in "user[password]", with: "password"
        click_button(I18n.t("settings.register"))
      end
      expect(page).to have_content("Password confirmation doesn't match Password")
    end

    scenario 'with valid information' do
      click_link I18n.t("settings.register")
      within "#new_user" do
        fill_in "user[email]", with: "email@email.com"
        fill_in "user[password]", with: "12345678"
        fill_in "user[password_confirmation]", with: "12345678"
        click_button(I18n.t("settings.register"))
      end
      expect(page).to have_content(I18n.t("devise.registrations.signed_up"))
      expect(page).to have_link(I18n.t("settings.settings"))
      expect(page).to have_link(I18n.t("sessions.log_out"), href: destroy_user_session_path)
    end
  end

  feature 'log in the user' do

    scenario {expect(page).to have_link(I18n.t("sessions.log_in"), href: new_user_session_path)}

    feature 'should have form for log in' do
      background do
        click_link(I18n.t("sessions.log_in"))
      end
      scenario {expect(page).to have_field("user[email]")}
      scenario {expect(page).to have_field("user[password]")}
      scenario {expect(page).to have_field("user[remember_me]")}
      scenario {expect(page).to have_button(I18n.t("sessions.log_in"))}
      scenario {expect(page).to have_link(I18n.t("settings.register"), href: new_user_registration_path)}
      scenario {expect(page).to have_link(I18n.t("password.fogot_password"), href: new_user_password_path)}
      scenario {expect(page).to have_link("", href: user_omniauth_authorize_path(:facebook))}
    end
    scenario 'with blank email or blank password' do
      click_link I18n.t("sessions.log_in")
      within "#new_user" do
        fill_in "user[email]", with: customer.email
        click_button(I18n.t("sessions.log_in"))
      end
      expect(page).to have_content("Invalid email or password.")
    end

    scenario 'with valid information' do
      click_link I18n.t("sessions.log_in")
      within "#new_user" do
        fill_in "user[email]", with: customer.email
        fill_in "user[password]", with: customer.password
        click_button(I18n.t("sessions.log_in"))
      end
      expect(page).to have_content(I18n.t("devise.sessions.signed_in"))
      expect(page).to have_link(I18n.t("settings.settings"))
      expect(page).to have_link(I18n.t("sessions.log_out"), href: destroy_user_session_path)
    end
  end

  feature 'edit user settings' do
    background do
      login_as customer, :scope => :user
      visit edit_user_registration_path(customer)
    end
    feature 'should have form for settings billing address' do
      scenario {expect(page).to have_field("user[billing_address_attributes][first_name]")}
      scenario {expect(page).to have_field("user[billing_address_attributes][last_name]")}
      scenario {expect(page).to have_field("user[billing_address_attributes][address]")}
      scenario {expect(page).to have_field("user[billing_address_attributes][city]")}
      scenario {expect(page).to have_select("user[billing_address_attributes][country_id]")}
      scenario {expect(page).to have_field("user[billing_address_attributes][zipcode]")}
      scenario {expect(page).to have_field("user[billing_address_attributes][phone]")}
    end

    feature 'fill in fields for billing address' do

      background do
        fill_in 'user[current_password]', with: customer.password
      end
      scenario 'with blank first name' do
        fill_in_address(billing_address, "billing")
        fill_in 'user[billing_address_attributes][first_name]', with: ""
        click_button(I18n.t("settings.edit_info.update_info"))
        expect(page).to have_content("Billing address first name can't be blank")
      end
      scenario 'with blank last name' do
        fill_in_address(billing_address, "billing")
        fill_in 'user[billing_address_attributes][last_name]', with: ""
        click_button(I18n.t("settings.edit_info.update_info"))
        expect(page).to have_content("Billing address last name can't be blank")
      end
      scenario 'with blank street address' do
        fill_in_address(billing_address, "billing")
        fill_in 'user[billing_address_attributes][address]', with: ""
        click_button(I18n.t("settings.edit_info.update_info"))
        expect(page).to have_content("Billing address address can't be blank")
      end
      scenario 'with blank city' do
        fill_in_address(billing_address, "billing")
        fill_in 'user[billing_address_attributes][city]', with: ""
        click_button(I18n.t("settings.edit_info.update_info"))
        expect(page).to have_content("Billing address city can't be blank")
      end
      scenario 'with blank country' do
        fill_in_address(billing_address, "billing", country = true)
        click_button(I18n.t("settings.edit_info.update_info"))
        expect(page).to have_content("Billing address country can't be blank")
      end
      scenario 'with blank zip code' do
        fill_in_address(billing_address, "billing")
        fill_in 'user[billing_address_attributes][zipcode]', with: ""
        click_button(I18n.t("settings.edit_info.update_info"))
        expect(page).to have_content("Billing address zipcode can't be blank")
      end
      scenario 'with blank phone' do
        fill_in_address(billing_address, "billing")
        fill_in 'user[billing_address_attributes][phone]', with: ""
        click_button(I18n.t("settings.edit_info.update_info"))
        expect(page).to have_content("Billing address phone can't be blank")
      end

      scenario 'with valid information' do
        fill_in_address(billing_address, "billing")
        click_button(I18n.t("settings.edit_info.update_info"))
        expect(page).to have_content(I18n.t("devise.registrations.updated"))
        click_link(I18n.t("settings.settings"))
        check_fields_address(billing_address, "billing")
      end
    end

    feature 'should have form for settings shipping address' do
      scenario {expect(page).to have_field("user[shipping_address_attributes][first_name]")}
      scenario {expect(page).to have_field("user[shipping_address_attributes][last_name]")}
      scenario {expect(page).to have_field("user[shipping_address_attributes][address]")}
      scenario {expect(page).to have_field("user[shipping_address_attributes][city]")}
      scenario {expect(page).to have_field("user[shipping_address_attributes][country_id]")}
      scenario {expect(page).to have_field("user[shipping_address_attributes][zipcode]")}
      scenario {expect(page).to have_field("user[shipping_address_attributes][phone]")}
    end

    feature 'fill in fields for shipping address' do
      background do
        fill_in 'user[current_password]', with: customer.password
      end
      scenario 'with blank first name' do
        fill_in_address(shipping_address, "shipping")
        fill_in 'user[shipping_address_attributes][first_name]', with: ""
        click_button(I18n.t("settings.edit_info.update_info"))
        expect(page).to have_content("Shipping address first name can't be blank")
      end
      scenario 'with blank last name' do
        fill_in_address(shipping_address, "shipping")
        fill_in 'user[shipping_address_attributes][last_name]', with: ""
        click_button(I18n.t("settings.edit_info.update_info"))
        expect(page).to have_content("Shipping address last name can't be blank")
      end
      scenario 'with blank street address' do
        fill_in_address(shipping_address, "shipping")
        fill_in 'user[shipping_address_attributes][address]', with: ""
        click_button(I18n.t("settings.edit_info.update_info"))
        expect(page).to have_content("Shipping address address can't be blank")
      end
      scenario 'with blank city' do
        fill_in_address(shipping_address, "shipping")
        fill_in 'user[shipping_address_attributes][city]', with: ""
        click_button(I18n.t("settings.edit_info.update_info"))
        expect(page).to have_content("Shipping address city can't be blank")
      end
      scenario 'with blank country' do
        fill_in_address(shipping_address, "shipping", country = true)
        click_button(I18n.t("settings.edit_info.update_info"))
        expect(page).to have_content("Shipping address country can't be blank")
      end
      scenario 'with blank zip code' do
        fill_in_address(shipping_address, "shipping")
        fill_in 'user[shipping_address_attributes][zipcode]', with: ""
        click_button(I18n.t("settings.edit_info.update_info"))
        expect(page).to have_content("Shipping address zipcode can't be blank")
      end
      scenario 'with blank phone' do
        fill_in_address(shipping_address, "shipping")
        fill_in 'user[shipping_address_attributes][phone]', with: ""
        click_button(I18n.t("settings.edit_info.update_info"))
        expect(page).to have_content("Shipping address phone can't be blank")
      end

      scenario 'with valid information' do
        fill_in_address(shipping_address, "shipping")
        click_button(I18n.t("settings.edit_info.update_info"))
        expect(page).to have_content(I18n.t("devise.registrations.updated"))
        click_link(I18n.t("settings.settings"))
        check_fields_address(shipping_address, "shipping")
      end
    end

    scenario {expect(page).to have_field("user[email]")}
    scenario {expect(page).to have_field("user[current_password]")}
    scenario {expect(page).to have_field("user[password]")}
    scenario {expect(page).to have_button(I18n.t("settings.edit_info.update_info"))}
    scenario {expect(page).to have_button(I18n.t("settings.edit_info.button_destroy_account"))}

    scenario "should have set current password" do
      click_button(I18n.t("settings.edit_info.update_info"))
      expect(page).to have_content("Current password can't be blank")
    end

    scenario 'set new email' do
      fill_in 'user[email]', with: "email@gmail.com"
      fill_in 'user[current_password]', with: customer.password
      click_button I18n.t("settings.edit_info.update_info")
      expect(page).to have_content(I18n.t("devise.registrations.updated"))
      customer.reload
      expect(customer.email).to eq("email@gmail.com")
      click_link(I18n.t("settings.settings"))
      expect(page).to have_field("user[email]", with: "email@gmail.com")
    end

  end

  feature 'log out user' do
    background do
      login_as customer, :scope => :user
      visit root_path
    end
    scenario 'with flash message' do
      click_link I18n.t("sessions.log_out")
      expect(page).to have_content(I18n.t("devise.sessions.signed_out"))
    end
  end

  feature 'destroy account user', js: true do
    background do
      login_as customer, :scope => :user
      visit edit_user_registration_path(customer)
    end

    scenario 'with confirmation' do
      click_button I18n.t("settings.edit_info.button_destroy_account")
      page.driver.browser.switch_to.alert.accept
      expect(page).to have_content(I18n.t("devise.registrations.destroyed"))
    end
  end
end
