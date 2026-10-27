# frozen_string_literal: true

class UserSerializer < ApplicationSerializer
  attributes :id, :name, :email, :verified, :locale, :created_at, :updated_at
end
