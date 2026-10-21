# frozen_string_literal: true

class UserMailer < ApplicationMailer
  # An email is read by its recipient, so it uses their saved language over the requester's.
  around_action { |_mailer, action| I18n.with_locale(params[:user].locale || I18n.locale, &action) }

  def password_reset
    @user = params[:user]
    @signed_id = @user.generate_token_for(:password_reset)

    mail to: @user.email, subject: t(".subject")
  end

  def email_verification
    @user = params[:user]
    @signed_id = @user.generate_token_for(:email_verification)

    mail to: @user.email, subject: t(".subject")
  end
end
