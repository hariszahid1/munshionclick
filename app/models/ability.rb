class Ability
  include CanCan::Ability

  def initialize(user)
    if user.present?
      super_admin_rules(user) if user.super_admin?
      shared_rules(user)
      user_rules(user)
      staff_rules(user) if user.staff?
      admin_rules(user) if user.admin?
      salesman_rules(user) if user.salesman?
      developer_rules(user) if user.developer?
      visitor_rules(user) if user.visitor?
      editor_rules(user) if user.editor?
    end
  end

  def visitor_rules(user)
    can :read, :all
  end

  def editor_rules(user)
    can :view, :all
    can :update, Compaign
    can :update, CompaignEntry
  end

  # for both users and visitors:
  def shared_rules(user)
    can :read, User
    can :read, Product
  end

  def user_rules(user)
    can :read, Product
    can :add, :all
  end

  def staff_rules(user)
    can :view, :all
    can :add, :all
    can :update, Product
    can :update, Compaign
    can :update, CompaignEntry
  end

  def salesman_rules(user)
    can :read, Product
    can :view, :SysUser
    can :add, :SysUser
    can :update, Compaign
    can :update, CompaignEntry
  end

  def admin_rules(user)
    can :add, :all
    can :view, :all
    can :update, :all
    can :update, Compaign
    can :update, CompaignEntry
  end

  def super_admin_rules(user)
    can :manage, :all
    can :view, :all
    can :destroy, :all
    can :update, Compaign
    can :update, CompaignEntry
  end

  def developer_rules(user)
    can :manage, :all
    can :view, :all
    can :destory, :all
    can :update, Compaign
    can :update, CompaignEntry
  end

  private

  # def user_has_accepted_investments_in?(user, campaign)
  #   campaign.accepted_investors.where(id: user.id).any?
  # end

end
