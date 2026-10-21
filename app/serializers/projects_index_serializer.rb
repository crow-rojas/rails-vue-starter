# frozen_string_literal: true

class ProjectsIndexSerializer < ApplicationSerializer
  has_many :projects
end
