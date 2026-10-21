# frozen_string_literal: true

class SessionsController < InertiaController
  limit_attempts only: :create
  skip_before_action :authenticate, only: %i[new create]
  before_action :require_no_authentication, only: %i[new create]
  before_action :set_session, only: :destroy

  def new
  end

  def create
    if (user = User.authenticate_by(email: params[:email], password: params[:password]))
      @session = user.sessions.create!
      cookies.signed.permanent[:session_token] = { value: @session.id, httponly: true }

      redirect_to dashboard_path, notice: t("sessions.signed_in")
    else
      redirect_to sign_in_path, alert: t("sessions.invalid")
    end
  end

  def destroy
    @session.destroy!
    Current.session = nil
    redirect_to settings_sessions_path, notice: t("sessions.signed_out"), inertia: { clear_history: true }
  end

  private

  def set_session
    @session = Current.user.sessions.find(params.expect(:id))
  end
end
