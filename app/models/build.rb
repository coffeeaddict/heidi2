class Build
  include Mongoid::Document

  # belongs to a repository
  embedded_in :repository
  embeds_one :log

  # a build is-a commit
  field :number, type: Integer, default: 0
  field :commit, type: String
  field :created_at, type: DateTime, default: ->() { Time.now }

  # can be deployed
  field :deployed, type: Boolean
  field :deployed_at, type: DateTime
  field :tag, type: String

  # has a status
  field :status, type: String, default: 'pending'

  validates :status, presence: true, inclusion: { in: %w[pending skipped passed failed building] }

  after_create :create_log

  after_save ->() { self.repository.project.determine_status }

  def summary
    repository.git.commit(self.commit).message.split(/\n/).first
  rescue
    "---"
  end
end
