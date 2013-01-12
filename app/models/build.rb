class Build
  include Mongoid::Document

  # belongs to a repository
  embedded_in :repository
  embeds_one :log

  # a build is-a commit
  field :commit, type: String

  # can be deployed
  field :deployed, type: Boolean
  field :deployed_at, type: DateTime
  field :tag, type: String

  # has a status
  field :status, type: String

  validates :status, presence: true, inclusion: { in: %w[passing failing building] }
end
