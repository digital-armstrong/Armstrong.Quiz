# frozen_string_literal: true

module Admin
  class UserAnswersController < BaseController
    before_action :set_user_answer

    def update
      authorize @user_answer
      return head :unprocessable_entity if @user_answer.question.answer_options.any?
      return head :unprocessable_entity unless @user_answer.answer_option_id.nil?

      user_id = @user_answer.quiz_attempt.user_id
      anchor = ActionView::RecordIdentifier.dom_id(@user_answer)
      if @user_answer.update(user_answer_params)
        redirect_to admin_result_path(user_id, anchor: anchor), notice: t("admin.user_answers.updated")
      else
        redirect_to admin_result_path(user_id, anchor: anchor), alert: @user_answer.errors.full_messages.to_sentence
      end
    end

    private

    def set_user_answer
      @user_answer = UserAnswer.find(params[:id])
    end

    def user_answer_params
      params.require(:user_answer).permit(:admin_correct)
    end
  end
end
