# frozen_string_literal: true

module UserAccountUpdates
  extend ActiveSupport::Concern

  private

  def update_user_account(user, params)
    p = params.respond_to?(:to_unsafe_h) ? params : ActionController::Parameters.new(params)
    if p[:password].present?
      user.update_with_password(p)
    else
      user.update_without_password(p.except(:password, :password_confirmation, :current_password))
    end
  end
end
