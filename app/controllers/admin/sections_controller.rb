# frozen_string_literal: true

module Admin
  class SectionsController < BaseController
    before_action :require_full_admin!
    before_action :set_section, only: %i[show edit update destroy]

    def index
      @sections = policy_scope(Section).includes(:categories).order(:title)
    end

    def show
      authorize @section
    end

    def new
      @section = Section.new
      authorize @section
    end

    def create
      @section = Section.new(section_params)
      authorize @section
      if @section.save
        redirect_to admin_section_path(@section), notice: t("admin.sections.created")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @section
    end

    def update
      authorize @section
      if @section.update(section_params)
        redirect_to admin_section_path(@section), notice: t("admin.sections.updated")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @section
      if @section.destroy
        redirect_to admin_sections_path, notice: t("admin.sections.destroyed")
      else
        redirect_to admin_sections_path, alert: @section.errors.full_messages.to_sentence.presence || t("admin.sections.destroy_restricted")
      end
    end

    private

    def set_section
      @section = Section.includes(categories: :questions).find(params[:id])
    end

    def section_params
      params.require(:section).permit(:title, :description, :enabled)
    end
  end
end
