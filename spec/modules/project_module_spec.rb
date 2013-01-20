require 'spec_helper'

describe ProjectModule do
  subject { ProjectModule.instance(nil, Kindergarten::HeadGoverness.new(nil)) }

  it "should have a project purpose" do
    subject.class.purpose.should == :project
  end
end

