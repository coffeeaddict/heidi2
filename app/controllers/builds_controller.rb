class BuildsController < ApplicationController
  before_filter {
    @project = sandbox.project.find(params[:project_id])
    @repository = @project.repositories.find(params[:repository_id])
  }

  def show
    @build = @repository.builds.find(params[:id])
  end

  def tail
    @build = @repository.builds.find(params[:id])
  end
end
