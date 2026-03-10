# frozen_string_literal: true

class UserAnswerPolicy < ApplicationPolicy
  def create?
    return false unless user&.student?

    record.quiz_attempt.user_id == user.id
  end

  def update?
    user&.admin_or_mentor?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user&.admin_or_mentor?
        scope.all
      elsif user
        scope.joins(:quiz_attempt).where(quiz_attempts: { user_id: user.id })
      else
        scope.none
      end
    end
  end
end
