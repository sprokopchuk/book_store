class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.admin?
      can :access, :rails_admin
      can :dashboard
      can :manage, [Book, Author, Category]
      can [:read, :update, :create, :destroy, :state, :all_events], Order
      can [:fill_in_address, :fill_in_delivery, :fill_in_payment, :confirm], Order do |order|
        order.real_price > 0
      end
      can :manage, User
      can :manage, Rating
      can :manage, Delivery
    elsif user.guest?
      can [:create, :destroy, :destroy_all], OrderItem, :order_id => user.current_order_in_progress.id
      can :update, Order, :user_id => user.id
      can :read, Rating, state: "approved"
    else
      can :complete, Order, :user_id => user.id, state: "in_queue"
      can [:fill_in_address, :fill_in_delivery, :fill_in_payment, :confirm], Order do |order|
        order.real_price > 0
      end
      can :create, Rating
      can :read, Rating, state: "approved"
      can [:create, :destroy, :destroy_all], OrderItem, :order_id => user.current_order_in_progress.id
      can [:read, :update], Order, :user_id => user.id
    end
  end
end
