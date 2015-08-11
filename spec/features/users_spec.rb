require 'rails_helper'

feature 'User management' do

  background  do
    visit root_path
  end
  given!(:customer) {FactoryGirl.create(:user)}
  given!(:billing_address) {FactoryGirl.create :address}
  given!(:shipping_address) {FactoryGirl.create :address}
  feature 'register a new user' do

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
        fill_in "user[first_name]", with: Faker::Name.name.split(" ")[0]
        fill_in "user[last_name]", with: Faker::Name.name.split(" ")[1]
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

    feature 'fill in fields for billing address' do

      background do
        fill_in 'user[current_password]', with: customer.password
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

    feature 'fill in fields for shipping address' do
      background do
        fill_in 'user[current_password]', with: customer.password
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

  feature 'log in via Facebook' do
    given!(:customer_with_facebook_account) {FactoryGirl.create :user, uid: 1234567, provider: "facebook"}
    background do
      visit root_path
      OmniAuth.config.test_mode = true
      OmniAuth.config.mock_auth[:facebook] = OmniAuth::AuthHash.new({
          provider: 'facebook',
          uid: customer_with_facebook_account.uid,
          info: {
            name: Faker::Name.name,
            email: customer_with_facebook_account.email
          },
          credentials: {
            token: "123456",
            expires_at: Time.now + 1.week
          }
      })
    end
    scenario 'login via facebook', js: true do
      click_link I18n.t("sessions.log_in")
      click_link '', href: user_omniauth_authorize_path(:facebook)
      expect(page).to have_content(I18n.t("devise.omniauth_callbacks.success", kind: "Facebook"))
    end
  end

 end


