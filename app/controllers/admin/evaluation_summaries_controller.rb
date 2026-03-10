module Admin
  class EvaluationSummariesController < BaseController
    def index
      @evaluations_by_admin = Evaluation
        .includes(:user, :admin)
        .order(User.arel_table[:email].asc)
        .group_by(&:admin)
    end
  end
end

