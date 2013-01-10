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
  
  expose :new_repository
  def new_repository(project, attr={})
    project.repositories.build(scrub(attr, :name, :uri))
  end

  expose :create_repository
  def create_repository(project, attr)
    project.repositories.create(scrub(attr, :name, :uri))
  end
end