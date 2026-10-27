# frozen_string_literal: true

class Settings::EmailsController < InertiaController
  limit_attempts only: :update

  def show
  end

  def update
    if !Current.user.update(user_params)
      redirect_to settings_email_path, inertia: { errors: Current.user.errors }
    elsif Current.user.email_previously_changed?
      UserMailer.with(user: Current.user).email_verification.deliver_later
      redirect_to settings_email_path, notice: t("settings.emails.changed")
    else
      redirect_to settings_email_path
    end
  end

  private

  def user_params
    params.permit(:email, :password_challenge).with_defaults(password_challenge: "")
  end
end
