# frozen_string_literal: true

class QuizAttemptPolicy < ApplicationPolicy
  def index?
    user&.admin?
  end

  def show?
    user&.admin? || record.user_id == user&.id
  end

  def create?
    user&.student?
  end

  def update?
    record.user_id == user&.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin?
        scope.all
      elsif user
        scope.where(user_id: user.id)
      else
        scope.none
      end
    end
  end
end
