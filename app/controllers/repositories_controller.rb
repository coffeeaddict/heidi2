class RepositoriesController < ApplicationController
  skip_before_filter :verify_authenticity_token, only: [ :hook ]
  skip_before_filter :authenticate_user!, only: [ :hook ]

  before_filter {
    sandbox.load_module(RepositoryModule)
    @project = sandbox.project.find(params[:project_id])
  }

  def new
    @repository = sandbox.repository.build(@project)
  end

  def create
    @repository = sandbox.repository.create(@project, params[:repository])
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

  def update
    @repository = @project.repositories.find(params[:id])
    sandbox.repository.update(@repository, params[:repository])

    redirect_to [ @project, @repository ]
  end

  def hook
    info = JSON.parse(params[:payload])
    repo = @project.repositories.find(params[:id])
    repo.build(info['after'])

    head :ok
  end

end
