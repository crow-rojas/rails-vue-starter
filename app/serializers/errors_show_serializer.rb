# frozen_string_literal: true

class ErrorsShowSerializer < ApplicationSerializer
  attributes :status
  typelize status: :number
end
