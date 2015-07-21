class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    if user.instance_of? Admin
      can :access, :rails_admin
      can :dashboard
      can :manage, [Book, Author, Category]
      can [:update, :read], Order
    elsif user.instance_of? Customer
      can :manage, Order, :customer_id => user.id
    end
  end
end
