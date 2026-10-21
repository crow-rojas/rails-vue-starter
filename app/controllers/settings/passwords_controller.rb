# frozen_string_literal: true

class Settings::PasswordsController < InertiaController
  limit_attempts only: :update
  before_action :set_user

  def show
  end

  def update
    @user.assign_attributes(user_params)
    if @user.save(context: :password_change)
      redirect_to settings_password_path, notice: t("settings.passwords.changed")
    else
      redirect_to settings_password_path, inertia: { errors: @user.errors }
    end
  end

  private

  def set_user
    @user = Current.user
  end

  def user_params
    params.permit(:password, :password_confirmation, :password_challenge).with_defaults(password_challenge: "")
  end
end
