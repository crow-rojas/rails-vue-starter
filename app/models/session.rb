# frozen_string_literal: true

class Session < ApplicationRecord
  # An absolute lifetime: a session ends 30 days after sign in, however active it is (ADR-003).
  LIFETIME = 30.days

  belongs_to :user

  scope :expired, -> { where(created_at: ...LIFETIME.ago) }

  # A plain primary-key lookup, then the lifetime check: a time-bound scope would change its query on
  # every request, so the query cache could never serve it.
  def self.find_active(id)
    find_by(id:)&.then { it unless it.expired? }
  end

  def expired? = created_at < LIFETIME.ago

  before_create do
    self.user_agent = Current.user_agent
    self.ip_address = Current.ip_address
  end
end
