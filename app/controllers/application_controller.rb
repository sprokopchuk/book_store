class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected
    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:current_password, :password, :email,
                                  :billing_address_attributes => [:first_name, :last_name, :address, :city, :country_id, :zipcode, :phone],
                                  :shipping_address_attributes => [:first_name, :last_name, :address, :city, :country_id, :zipcode, :phone]) }
    end
end
