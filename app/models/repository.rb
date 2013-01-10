require 'fileutils'
require 'git'

class Repository
  include Mongoid::Document

  field :name, type: String
  field :uri, type: String
  field :default_branch, type: String, default: "master"
  field :last_head, type: String

  embedded_in :project

  has_many :commits
  has_many :builds

  validates :name, :uri, :presence => true

  after_create ->{
    self.delay.update_head unless !self.persisted?
  }

  def update_head
    self.update_attributes( last_head: git.object('HEAD').sha )
  end

  def path
    path = File.join(Heidi2::Application.config.repositories.root, project._id, _id)

    root = File.dirname(path)
    if not File.exists?(root)
      FileUtils.mkdir_p(root)
    end

    return path
  end

  def git
    if File.exists?(path)
      Git.open(path)
    else
      clone
    end
  end

  def clone
    Git.clone(uri, path)
  end
end
