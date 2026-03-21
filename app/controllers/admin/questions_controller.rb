# frozen_string_literal: true

module Admin
  class QuestionsController < BaseController
    before_action :require_full_admin!
    before_action :set_question, only: %i[show edit update destroy]
    before_action :set_categories, only: %i[new edit create update new_option_fields]

    def index
      @questions = policy_scope(Question).includes(:category).order("categories.title", :id)
    end

    def show
      authorize @question
      @answer_options = @question.answer_options.order(:position)
    end

    def new
      @question = Question.new
      authorize @question
    end

    def create
      @question = Question.new(question_params)
      authorize @question
      if @question.save
        redirect_to admin_question_path(@question), notice: t("admin.questions.created")
      else
        set_categories
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @question
    end

    def update
      authorize @question
      if @question.update(question_params)
        redirect_to admin_question_path(@question), notice: t("admin.questions.updated")
      else
        set_categories
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @question
      @question.destroy
      redirect_to admin_questions_path, notice: t("admin.questions.destroyed")
    end

    def new_option_fields
      authorize Question, :create?
      index = params[:index].to_i
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.append(
            "answer_options_container",
            partial: "answer_option_fields",
            locals: { index: index }
          ), content_type: "text/vnd.turbo-stream.html"
        end
        format.html { redirect_to new_admin_question_path, notice: t("admin.answer_options.add") }
      end
    end

    private

    def set_question
      @question = Question.includes(:answer_options).find(params[:id])
    end

    def set_categories
      @categories = Category.order(:title)
    end

    def question_params
      params.require(:question).permit(
        :category_id, :title, :body, :pool_tag,
        answer_options_attributes: %i[id body correct position _destroy]
      )
    end
  end
end