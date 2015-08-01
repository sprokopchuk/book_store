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
    else
      can :manage, Order, :user_id => user.id
    end
  end
end
