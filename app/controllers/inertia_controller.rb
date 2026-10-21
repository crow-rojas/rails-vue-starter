# frozen_string_literal: true

class InertiaController < ApplicationController
  include Alba::Inertia::Controller

  inertia_share { SharedPropsSerializer.new(self).to_inertia }
  inertia_share do
    {
      locale: I18n.locale.to_s,
      translations: InertiaRails.once(key: "translations.#{I18n.locale}") { { ui: I18n.t("ui") } }
    }
  end

  # Inertia shows any non-Inertia response in a modal meant for development, so production answers
  # with an error page instead (https://inertia-rails.dev/guide/error-handling). Errors outside an
  # Inertia controller, or in this handler, still fall back to public/404.html and 500.html.
  # Declared first: rescue_from tries the last matching handler first.
  rescue_from StandardError, with: :render_error_page

  # Inertia shows a 422 as an error modal; an expired form should just ask the user to retry.
  # The token check runs before switch_locale, so the message picks its language itself.
  rescue_from ActionController::InvalidAuthenticityToken do
    redirect_back_or_to root_path, alert: t("errors.page_expired", locale: current_locale)
  end

  private

  # Where requests are local (development, test) it raises, so the debug page shows the trace.
  def render_error_page(exception)
    raise exception if request.get_header("action_dispatch.show_detailed_exceptions")

    status = ActionDispatch::ExceptionWrapper.new(nil, exception).status_code
    # A rescued exception skips Rails' error reporting; a server error still needs to reach it.
    Rails.error.report(exception) if status >= 500
    # switch_locale has already unwound by the time a rescue_from handler runs.
    I18n.with_locale(current_locale) do
      render_inertia "errors/show", serializer: ErrorsShowSerializer, locals: { status: }, status:
    end
  end
end
