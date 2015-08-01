class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_action :configure_permitted_parameters, if: :devise_controller?
  helper_method :current_or_guest_user

  def current_or_guest_user
    if current_user
      if session[:guest_user_id] && session[:guest_user_id] != current_user.id
        logging_in
        guest_user(with_retry = false).try(:destroy)
        session[:guest_user_id] = nil
      end
      current_user
    else
      guest_user
    end
  end

  def guest_user(with_retry = true)
    @cached_guest_user ||= User.find(session[:guest_user_id] ||= create_guest_user.id)

  rescue ActiveRecord::RecordNotFound # if session[:guest_user_id] invalid
     session[:guest_user_id] = nil
     guest_user if with_retry
  end

  private
    # called (once) when the user logs in, insert any code your application needs
    # to hand off from guest_user to current_user.
    def logging_in
      User.find_by(email: guest_user.email).destroy
          # For example:
      # guest_comments = guest_user.comments.all
      # guest_comments.each do |comment|
        # comment.user_id = current_user.id
        # comment.save!
      # end
      # Add items in guest's shopping card into user's shopping card
    end

    def create_guest_user
      u = User.create(:email => "guest_#{Time.now.to_i}#{rand(100)}@gmail.com", :guest => true)
      u.save!(:validate => false)
      session[:guest_user_id] = u.id
      u
  end

  protected
    def configure_permitted_parameters
      devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:current_password, :password, :email,
                                  :billing_address_attributes => [:first_name, :last_name, :address, :city, :country_id, :zipcode, :phone],
                                  :shipping_address_attributes => [:first_name, :last_name, :address, :city, :country_id, :zipcode, :phone]) }
    end
end
