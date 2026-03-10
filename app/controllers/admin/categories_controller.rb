# frozen_string_literal: true

module Admin
  class CategoriesController < BaseController
    before_action :require_full_admin!
    before_action :set_category, only: %i[show edit update destroy]

    def index
      @categories = policy_scope(Category).order(:title)
    end

    def show
      authorize @category
    end

    def new
      @category = Category.new
      authorize @category
    end

    def create
      @category = Category.new(category_params)
      authorize @category
      if @category.save
        redirect_to admin_category_path(@category), notice: t("admin.categories.created")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @category
    end

    def update
      authorize @category
      if @category.update(category_params)
        redirect_to admin_category_path(@category), notice: t("admin.categories.updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @category
      @category.destroy
      redirect_to admin_categories_path, notice: t("admin.categories.destroyed")
    end

    private

    def set_category
      @category = Category.find(params[:id])
    end

    def category_params
      params.require(:category).permit(:title, :description)
    end
  end
end
