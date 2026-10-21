# frozen_string_literal: true

class ProjectSerializer < ApplicationSerializer
  attributes :id, :name, :created_at, :updated_at
end
