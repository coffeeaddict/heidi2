require 'spec_helper'

describe BuildInstruction do
  it { should validate_presence_of :script }
  it { should be_embedded_in :repository }
  it "should have a blocking boolean" do
    x = BuildInstruction.new( script: "echo ''", blocking: true )
    x.should be_blocking

    y = BuildInstruction.new( script: "echo ''", blocking: false )
    y.should_not be_blocking
  end
end
