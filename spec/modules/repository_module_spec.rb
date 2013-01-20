require 'spec_helper'

describe RepositoryModule do
  subject { RepositoryModule.instance(nil, Kindergarten::HeadGoverness.new(nil)) }

  it "should have a repository purpose" do
    subject.class.purpose.should == :repository
  end
end

