class HomeController < ApplicationController
  def index
    @projects = Project.all.page(params[:page]).per(10)
  end
end
