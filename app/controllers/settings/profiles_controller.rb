# frozen_string_literal: true

class Settings::ProfilesController < InertiaController
  def show
  end

  def update
    if Current.user.update(user_params)
      redirect_to settings_profile_path, notice: t("settings.profiles.updated", locale: Current.user.locale || I18n.locale)
    else
      redirect_to settings_profile_path, inertia: { errors: Current.user.errors }
    end
  end

  private

  def user_params
    params.permit(:name, :locale)
  end
end
