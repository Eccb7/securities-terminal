class PortfolioPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin? || user.super_admin?
        # Admins can see all portfolios in their organization
        scope.where(organization_id: user.organization_id)
      else
        # Regular users can only see their own portfolios
        scope.where(user_id: user.id)
      end
    end
  end

  def index?
    true
  end

  def show?
    # Users can view their own portfolios, or admins can view all in org
    record.user_id == user.id || user.admin? || user.super_admin?
  end

  def create?
    user.present?
  end

  def new?
    create?
  end

  def update?
    # Users can update their own portfolios, or admins can update any
    record.user_id == user.id || user.admin? || user.super_admin?
  end

  def edit?
    update?
  end

  def destroy?
    # Users can delete their own portfolios, or admins can delete any
    record.user_id == user.id || user.admin? || user.super_admin?
  end
end
