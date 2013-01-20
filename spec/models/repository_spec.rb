require 'spec_helper'

describe Repository do
  it { should embed_many :build_instructions }
  it { should embed_many :builds }
  it { should be_embedded_in :project }

  it { should validate_presence_of :name }
  it { should validate_presence_of :uri }
end
