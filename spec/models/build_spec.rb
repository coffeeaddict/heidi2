require 'spec_helper'

describe Build do
  it { should validate_presence_of :status }
  it { ensure_inclusion_of(:status).in_array %w[pending passed failed building] }
end
