class ApplicationController < ActionController::Base
  include KindergartenHelper
  helper :kindergarten

  protect_from_forgery
  before_filter :authenticate_user!
  before_filter { sandbox.load_module(ProjectModule) }  
end
