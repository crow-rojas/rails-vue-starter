require "application_system_test_case"

class ProjectsTest < ApplicationSystemTestCase
  setup { sign_in_as users(:one) }

  test "creating, renaming and deleting a project" do
    click_on "Projects"
    assert_selector "h1", text: "Projects"
    assert_accessible

    click_on "New project"
    assert_selector "h1", text: "New project"
    assert_accessible
    fill_in "Name", with: "Annual report"
    click_on "Save"

    assert_text "Project created"
    assert_selector "h1", text: "Annual report"
    assert_accessible

    click_on "Edit"
    assert_selector "h1", text: "Edit project"
    assert_accessible
    fill_in "Name", with: "Annual report 2026"
    click_on "Save"
    assert_selector "h1", text: "Annual report 2026"

    accept_confirm { click_on "Delete" }
    assert_text "Project deleted"
    assert_no_text "Annual report 2026"
  end

  test "a duplicate name shows the error next to the field" do
    visit new_project_path
    fill_in "Name", with: projects(:website).name
    click_on "Save"

    assert_text "has already been taken"
    assert_accessible
  end
end
