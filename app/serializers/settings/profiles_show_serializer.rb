# frozen_string_literal: true

module Settings
  class ProfilesShowSerializer < ApplicationSerializer
    typelize "string[]"
    attribute(:locales) { I18n.available_locales.map(&:to_s) }
  end
end
