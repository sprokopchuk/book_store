class Ability
  include CanCan::Ability

  def initialize(user)
    if user && user.instance_of? Admin
      can :access, :rails_admin
      can :dashboard
      can :manage, [Book, Author, Category]
      can [:change_state, :read], Order
    elsif user.instance_of? Customer
      can :manage, Order, :customer_id => user.id
    end
  end
end
