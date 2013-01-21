class BuildEventsController < ApplicationController
  def index
    render partial: "live_updates/index"
  end

  def show
    render BuildEvent.find(params[:id])
  end
end
