require 'spec_helper'

describe ProjectModule do
  subject {
    ProjectModule.instance(nil, Kindergarten::HeadGoverness.new(nil))
  }

  before(:each) do
    @project = Project.create(name: "test")
  end

  it "should have a project purpose" do
    subject.class.purpose.should == :project
  end

  it "should find projects" do
    subject.find("test").should == @project
  end

  it "should create projects" do
    project = subject.create( name: "test 2" )
    project.should be_kind_of(Project)
    project.name.should == "test 2"
    project.status.should == "pending"
  end

end

