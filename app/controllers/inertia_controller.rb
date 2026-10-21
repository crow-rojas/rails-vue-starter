# frozen_string_literal: true

class InertiaController < ApplicationController
  include Alba::Inertia::Controller

  inertia_share { SharedPropsSerializer.new(self).to_inertia }

  # Inertia shows a 422 as an error modal; an expired form should just ask the user to retry.
  rescue_from ActionController::InvalidAuthenticityToken do
    redirect_back_or_to root_path, alert: "The page expired. Please try again"
  end
end
