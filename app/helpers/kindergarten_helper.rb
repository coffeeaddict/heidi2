module KindergartenHelper
  def sandbox
    @sandbox ||= Kindergarten.sandbox(current_user)
  end
  
  def current_user?
    !current_user.nil?
  end
end