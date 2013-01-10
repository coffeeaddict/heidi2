class ProjectsController < ApplicationController
  def index
    @projects = Project.all.page(params[:page] || 1)
  end
  
  def new
    @project = Project.new
  end
  
  def create
    @project = sandbox.project.create(params[:project])
    return(render :new) unless @project.valid?

    redirect_to @project
  end
  
  def show
    @project = sandbox.project.find(params[:id])
  end
end