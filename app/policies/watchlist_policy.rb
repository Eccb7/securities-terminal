class WatchlistPolicy < ApplicationPolicy
  def index?
    true # All authenticated users can view watchlists
  end

  def show?
    user_owns_record? || user.admin_or_above?
  end

  def create?
    true # All authenticated users can create watchlists
  end

  def update?
    user_owns_record? || user.admin_or_above?
  end

  def destroy?
    user_owns_record? || user.admin_or_above?
  end

  def add_security?
    update?
  end

  def remove_security?
    update?
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
