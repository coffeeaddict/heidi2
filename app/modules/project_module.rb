class ProjectModule < Kindergarten::Perimeter
  purpose :project
  govern do
    can :manage, Project
  end

  expose :find
  def find(id)
    Project.find(id)
  end

  expose :create
  def create(attr)
    Project.create( scrub(attr, :name).merge(status: 'pending') )
  end
end
