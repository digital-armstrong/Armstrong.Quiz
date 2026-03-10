# frozen_string_literal: true

module Users
  class RegistrationsController < Devise::RegistrationsController
    before_action :configure_permitted_parameters, if: :devise_controller?

    protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:consent_to_personal_data, profile_attributes: %i[first_name last_name middle_name]])
    end

    def build_resource(hash = {})
      super
      resource.build_profile if resource.profile.nil?
      resource
    end
  end
end
