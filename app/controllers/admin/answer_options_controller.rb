# frozen_string_literal: true

module Admin
  class AnswerOptionsController < BaseController
    before_action :require_full_admin!
    before_action :set_question
    before_action :set_answer_option, only: %i[edit update destroy]

    def new
      @answer_option = @question.answer_options.build(
        position: (@question.answer_options.maximum(:position) || 0) + 1
      )
      authorize @answer_option
    end

    def create
      @answer_option = @question.answer_options.build(answer_option_params)
      authorize @answer_option
      if @answer_option.save
        redirect_to admin_question_path(@question), notice: t("admin.answer_options.created")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @answer_option
    end

    def update
      authorize @answer_option
      if @answer_option.update(answer_option_params)
        redirect_to admin_question_path(@question), notice: t("admin.answer_options.updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @answer_option
      @answer_option.destroy
      redirect_to admin_question_path(@question), notice: t("admin.answer_options.destroyed")
    end

    private

    def set_question
      @question = Question.find(params[:question_id])
    end

    def set_answer_option
      @answer_option = @question.answer_options.find(params[:id])
    end

    def answer_option_params
      params.require(:answer_option).permit(:body, :correct, :position)
    end
  end
end