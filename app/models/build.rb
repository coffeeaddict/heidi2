class Build
  include Mongoid::Document

  # a build is-a commit  
  has_one :commit

  # can be deployed 
  field :deployed, type: Boolean
  field :deployed_at, type: DateTime
  field :tag, type: String

  # has a status
  field :status, type: String
  
  validates :status, presence: true, inclusion: { in: %w[passing failing building] }
end