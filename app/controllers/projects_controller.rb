# frozen_string_literal: true

# The reference resource: copy its shape for new ones (docs/adr/005-application-shape.md).
class ProjectsController < InertiaController
  before_action :set_project, only: %i[show edit update destroy]

  def index
    @projects = Current.user.projects.order(:name)
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    project = Current.user.projects.new(project_params)

    if project.save
      redirect_to project, notice: t("projects.created")
    else
      redirect_to new_project_path, inertia: { errors: project.errors }
    end
  end

  def update
    if @project.update(project_params)
      redirect_to @project, notice: t("projects.updated")
    else
      redirect_to edit_project_path(@project), inertia: { errors: @project.errors }
    end
  end

  def destroy
    @project.destroy!
    redirect_to projects_path, notice: t("projects.destroyed")
  end

  private

  # Scoping through Current.user is the authorization: another user's project is a 404.
  def set_project
    @project = Current.user.projects.find(params.expect(:id))
  end

  def project_params
    params.permit(:name)
  end
end
