# frozen_string_literal: true

class Settings::PasswordsController < InertiaController
  limit_attempts only: :update

  def show
  end

  def update
    Current.user.assign_attributes(user_params)
    if Current.user.save(context: :password_change)
      redirect_to settings_password_path, notice: t("settings.passwords.changed")
    else
      redirect_to settings_password_path, inertia: { errors: Current.user.errors }
    end
  end

  private

  def user_params
    params.permit(:password, :password_confirmation, :password_challenge).with_defaults(password_challenge: "")
  end
end
