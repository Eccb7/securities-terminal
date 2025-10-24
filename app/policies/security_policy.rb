class SecurityPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      # All users can view all active securities
      scope.active
    end
  end

  def index?
    true
  end

  def show?
    true
  end

  def create?
    user.admin? || user.super_admin?
  end

  def update?
    user.admin? || user.super_admin?
  end

  def destroy?
    user.super_admin?
  end

  def quote?
    true
  end

  def chart_data?
    true
  end
end
