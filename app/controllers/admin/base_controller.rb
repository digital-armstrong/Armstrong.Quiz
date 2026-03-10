# frozen_string_literal: true

module Admin
  class BaseController < ApplicationController
    before_action :authenticate_user!
    before_action :require_admin_or_mentor!

    layout "admin"

    private

    def require_admin_or_mentor!
      return if current_user&.admin_or_mentor?

      redirect_to root_path, alert: t("pundit.not_authorized")
    end

    def require_full_admin!
      return if current_user&.admin?

      redirect_to admin_root_path, alert: t("pundit.not_authorized")
    end
  end
end