# frozen_string_literal: true

module Admin
  class UsersController < BaseController
    before_action :require_full_admin!
    before_action :set_user, only: %i[show edit update destroy ban archive activate]

    def index
      @users = policy_scope(User).includes(:profile).order(:email)
    end

    def show
      authorize @user
    end

    def new
      @user = User.new
      @user.build_profile
      authorize @user
    end

    def create
      @user = User.new(user_params)
      @user.role = params[:user][:role].presence || "student"
      @user.state = "active"
      @user.consent_to_personal_data = true
      authorize @user
      if @user.save
        redirect_to admin_user_path(@user), notice: t("admin.users.created")
      else
        @user.build_profile if @user.profile.nil?
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      authorize @user
      @user.build_profile if @user.profile.nil?
    end

    def update
      authorize @user
      if @user.update(user_params)
        redirect_to admin_user_path(@user), notice: t("admin.users.updated")
      else
        @user.build_profile if @user.profile.nil?
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      authorize @user
      @user.destroy
      redirect_to admin_users_path, notice: t("admin.users.destroyed")
    end

    def ban
      authorize @user, :ban?
      @user.update!(state: "banned")
      redirect_to admin_users_path, notice: t("admin.users.banned")
    end

    def archive
      authorize @user, :archive?
      @user.update!(state: "archived")
      redirect_to admin_users_path, notice: t("admin.users.archived")
    end

    def activate
      authorize @user, :activate?
      @user.update!(state: "active")
      redirect_to admin_users_path, notice: t("admin.users.activated")
    end

    private

    def set_user
      @user = User.includes(:profile).find(params[:id])
    end

    def user_params
      p = params.require(:user).permit(:email, :password, :password_confirmation, :role,
        profile_attributes: %i[id first_name last_name middle_name])
      if p[:password].blank?
        p.delete(:password)
        p.delete(:password_confirmation)
      end
      p
    end
  end
end
