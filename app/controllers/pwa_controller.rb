# frozen_string_literal: true

# Replaces Rails::PwaController so these responses get the user's language (ADR-007).
class PwaController < ApplicationController
  skip_before_action :authenticate
  # Browsers fetch the worker as a script, which the cross-origin JavaScript check would block.
  # It holds no user data, the same reason Rails::PwaController skips it.
  skip_after_action :verify_same_origin_request, only: :service_worker

  def manifest
  end

  def service_worker
  end

  def offline
    render layout: false
  end
end
