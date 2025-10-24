class OrderPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin? || user.super_admin? || user.compliance_officer?
        # Admins and compliance can see all orders in their organization
        scope.joins(:user).where(users: { organization_id: user.organization_id })
      else
        # Regular users can only see their own orders
        scope.where(user_id: user.id)
      end
    end
  end

  def index?
    true
  end

  def show?
    # Users can view their own orders, or admins/compliance can view all
    record.user_id == user.id || user.admin? || user.super_admin? || user.compliance_officer?
  end

  def create?
    # Only traders and above can create orders
    user.can_trade?
  end

  def new?
    create?
  end

  def cancel?
    # Users can cancel their own orders, or admins can cancel any
    record.user_id == user.id || user.admin? || user.super_admin?
  end

  def modify?
    # Users can modify their own orders, or admins can modify any
    record.user_id == user.id || user.admin? || user.super_admin?
  end

  def destroy?
    user.super_admin?
  end
end
