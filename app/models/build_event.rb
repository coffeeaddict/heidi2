class BuildEvent
  include Mongoid::Document

  field :message, type: String
  field :created_at, type: DateTime, default: ->() { Time.now }

  belongs_to :project
  field :repository_id, type: String
  field :build_id, type: String

  before_save ->() {
    self.repository = self.build.repository if self.build && !self.repository
    self.project    = self.repository.project if self.repository && !self.project
  }

  after_create ->() {
    FayeClient.publish("/build_events", new: true)
  }

  after_update ->() {
    FayeClient.publish("/build_events", updated: self._id.to_s)
  }

  def repository=(repository)
    @repository = repository
    self.repository_id = repository._id
  end
  def repository
    @repository ||= project.repositories.find(repository_id)
  end

  def build=(build)
    @build = build
    self.build_id = build._id
  end
  def build
    @build ||= repository.builds.find(build_id)
  end

  def set_message(msg)
    update_attributes(message: msg)
    build.log.append("[event] #{msg}") unless msg.blank?
   end

  delegate :status, to: :build
end
