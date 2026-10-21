# frozen_string_literal: true

require "test_helper"

class ProjectTest < ActiveSupport::TestCase
  test "squishes the name" do
    assert_equal "Q4 roadmap", Project.new(name: "  Q4   roadmap ").name
  end

  test "requires a name" do
    project = users(:one).projects.new(name: " ")

    assert_not project.valid?
    assert_includes project.errors.details[:name], { error: :blank }
  end

  test "names are unique per user, not across users" do
    assert_not users(:one).projects.new(name: projects(:website).name).valid?
    assert users(:two).projects.new(name: projects(:website).name).valid?
  end

  test "the database rejects a duplicate name for the same user" do
    assert_raises(ActiveRecord::RecordNotUnique) do
      users(:one).projects.new(name: projects(:website).name).save(validate: false)
    end
  end
end
