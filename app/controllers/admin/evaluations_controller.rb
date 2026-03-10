# frozen_string_literal: true

module Admin
  class EvaluationsController < BaseController
    before_action :set_user, only: %i[new create]
    before_action :set_evaluation, only: %i[edit update]

    def new
      @evaluation = @user.evaluations_received.build
      @evaluation.admin_id = current_user.id
    end

    def create
      @user = User.find(params[:user_id])
      @evaluation = @user.evaluations_received.build(evaluation_params)
      @evaluation.admin_id = current_user.id
      authorize @evaluation
      if @evaluation.save
        redirect_to admin_result_path(@user), notice: t("admin.evaluations.created")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @evaluation
    end

    def update
      authorize @evaluation
      if @evaluation.update(evaluation_params)
        redirect_to admin_result_path(@evaluation.user_id), notice: t("admin.evaluations.updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def set_user
      @user = User.find(params[:user_id])
    end

    def set_evaluation
      @evaluation = Evaluation.find(params[:id])
    end

    def evaluation_params
      params.require(:evaluation).permit(
        :score, :comment, :recommendation,
        :technical_knowledge, :argumentation, :creative_thinking,
        :team_collaboration, :leadership, :execution, :quick_learning
      )
    end
  end
end