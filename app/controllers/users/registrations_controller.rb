# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    include UserAccountUpdates

    before_action :configure_permitted_parameters, if: :devise_controller?

    def edit
      redirect_to edit_profile_path
    end

    protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:consent_to_personal_data, profile_attributes: %i[first_name last_name middle_name]])
      devise_parameter_sanitizer.permit(:account_update, keys: [:email, { profile_attributes: %i[id first_name last_name middle_name] }])
    end

    def update_resource(resource, params)
      update_user_account(resource, params)
    end

    def after_update_path_for(resource)
      profile_path
    end

    def build_resource(hash = {})
      super
      resource.build_profile if resource.profile.nil?
      resource
    end
  end
end
