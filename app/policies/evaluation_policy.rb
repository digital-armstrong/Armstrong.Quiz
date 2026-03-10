# frozen_string_literal: true

class EvaluationPolicy < ApplicationPolicy
  def index?
    user&.admin_or_mentor?
  end

  def show?
    user&.admin_or_mentor?
  end

  def create?
    user&.admin_or_mentor?
  end

  def update?
    user&.admin_or_mentor?
  end

  def destroy?
    user&.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      user&.admin_or_mentor? ? scope.all : scope.none
    end
  end
end
