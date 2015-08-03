class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.admin?
      can :access, :rails_admin
      can :dashboard
      can :manage, [Book, Author, Category]
      can :manage, Order
      can :manage, OrderItem
      can :manage, User
      can :manage, Rating
    elsif user.guest?
      can :manage, OrderItem, :user_id => user.id
      can :manage, Order, :user_id => user.id
    else
      can [:read, :create], Rating
      can :manage, OrderItem, :user_id => user.id
      can :manage, Order, :user_id => user.id
    end
  end
end
