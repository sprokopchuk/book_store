class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.admin?
      can :access, :rails_admin
      can :dashboard
      can :manage, [Book, Author, Category]
      can [:read, :update, :create, :destroy, :state, :all_events], Order
      can :complete, Order, :user_id => user.id, state: "confirm"
      can [:create, :destroy, :destroy_all], OrderItem, :order_id => user.current_order_in_progress.id
      can :manage, User
      can :manage, Rating
      can :manage, Delivery
      can :manage, WishList
    elsif user.guest?
      can [:create, :destroy, :destroy_all], OrderItem, :order_id => user.current_order_in_progress.id
      can :update, Order, :user_id => user.id
      can :read, Rating, state: "approved"
    else
      can :complete, Order, :user_id => user.id, state: "confirm"
      can :create, Rating
      can [:show, :add_book, :remove_book], WishList, user_id: user.id
      can :read, Rating, state: "approved"
      can [:create, :destroy, :destroy_all], OrderItem, :order_id => user.current_order_in_progress.id
      can [:read], Order, :user_id => user.id
    end
  end
end
