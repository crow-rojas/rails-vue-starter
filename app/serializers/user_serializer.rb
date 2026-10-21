# frozen_string_literal: true

class UserSerializer < ApplicationSerializer
  attributes :id, :name, :email, :verified, :locale, :created_at, :updated_at

  typelize :string?
  attribute :avatar do |_user|
    nil # Placeholder for avatar URL (e.g. Gravatar, Active Storage)
  end
end
