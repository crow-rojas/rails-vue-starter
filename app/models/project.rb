# frozen_string_literal: true

class Project < ApplicationRecord
  belongs_to :user

  normalizes :name, with: -> { it.squish }

  validates :name, presence: true, length: { maximum: 100 }, uniqueness: { scope: :user_id }
end
