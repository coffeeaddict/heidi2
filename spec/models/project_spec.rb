require 'spec_helper'

describe Project do
  it { should validate_presence_of :name }
  it { should validate_presence_of :status }
  it { should embed_many :repositories }

  it "should have a slug-id" do
    Project.create(name: "foo bar")._id.should == "foo-bar"
  end

  it "should assign a default status: pending" do
    p = Project.create( name: "not me" )
    p.status.should == "pending"
  end

  it "should set the own status based on worst repo" do
     p = Project.create( name: "foo bar" )

    template = %w[passed failed passed]
    3.times do |i|
      r = p.repositories.create(name: i, uri: i )
      r.builds.create( status: template[i] )
    end

    expect {
      p.determine_status
    }.to change {
      p.status
    }.to "failed"
  end

  it "should set the own status based on building repo" do
    p = Project.create( name: "foo bar" )

    template = %w[building failed passed]
    3.times do |i|
      r = p.repositories.create(name: "x", uri: "y" )
      r.builds.create( status: template[i] )
    end

    expect {
      p.determine_status
    }.to change {
      p.status
    }.to "building"
  end

  it "should return a collection of builds" do
    p = Project.create( name: "foo bar" )

    template = %w[building failed passed]
    3.times do |i|
      r = p.repositories.create(name: "#{i}i", uri: "y" )
      3.times do |ii|
        r.builds.create( status: template[ii] )
      end
    end

    p.builds.count.should == 9
  end

  it "should call build on the repositories" do
    p = Project.create( name: "foo" )
    r = p.repositories.create( name: "x", uri: "y" )
    r.expects(:build)

    p.build!
  end
end
