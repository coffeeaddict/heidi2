class RepositoriesController < ApplicationController
  before_filter { @project = sandbox.project.find(params[:project_id]) }

  def new
    @repository = sandbox.project.new_repository(@project)
  end

  def create
    @repository = sandbox.project.create_repository(@project, params[:repository])
  end

  def show
    @repository = @project.repositories.find(params[:id])
  end

  def destroy
    repository = @project.repositories.find(params[:id])
    repository.destroy

    @project.determine_status

    redirect_to @project
  end
end
