class AlertRulePolicy < ApplicationPolicy
  def index?
    true # All authenticated users can view alert rules
  end

  def show?
    user_owns_record? || user.admin_or_above?
  end

  def create?
    true # All authenticated users can create alert rules
  end

  def update?
    user_owns_record? || user.admin_or_above?
  end

  def destroy?
    user_owns_record? || user.admin_or_above?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.admin_or_above?
        scope.all
      else
        scope.where(user: user)
      end
    end
  end

  private

  def user_owns_record?
    record.user_id == user.id
  end
end
