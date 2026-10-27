# frozen_string_literal: true

require "test_helper"

class ProjectsControllerTest < ActionDispatch::IntegrationTest
  setup { sign_in users(:one) }

  test "lists only the user's projects, by name" do
    get projects_path

    assert_response :success
    assert_equal [ "Product launch", "Website redesign" ], inertia.props[:projects].pluck("name")
  end

  test "shows a project" do
    get project_path(projects(:website))

    assert_equal projects(:website).name, inertia.props[:project]["name"]
  end

  test "creates a project" do
    assert_difference -> { users(:one).projects.count } do
      post projects_path, params: { name: "Annual report" }
    end
    assert_redirected_to project_path(users(:one).projects.find_by!(name: "Annual report"))
    assert_equal I18n.t("projects.created"), flash[:notice]
  end

  test "sends a project with errors back to the form" do
    assert_no_difference "Project.count" do
      post projects_path, params: { name: projects(:website).name }
    end
    assert_redirected_to new_project_path
  end

  test "updates a project" do
    patch project_path(projects(:website)), params: { name: "Website v2" }

    assert_redirected_to project_path(projects(:website))
    assert_equal "Website v2", projects(:website).reload.name
  end

  test "deletes a project" do
    assert_difference "Project.count", -1 do
      delete project_path(projects(:website))
    end
    assert_redirected_to projects_path
  end

  test "another user's project does not exist for this user" do
    get project_path(projects(:others))
    assert_response :not_found

    patch project_path(projects(:others)), params: { name: "Mine now" }
    assert_response :not_found
    assert_equal "Someone else's project", projects(:others).reload.name
  end

  test "guests are sent to sign in" do
    sign_out
    get projects_path

    assert_redirected_to sign_in_path
  end
end
