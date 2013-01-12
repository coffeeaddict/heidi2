require 'fileutils'
require 'grit'

class Repository
  include Mongoid::Document

  field :name, type: String
  field :uri, type: String
  field :default_branch, type: String, default: "origin/develop"
  field :last_head, type: String

  embedded_in :project
  embeds_many :builds

  validates :name, :uri, :presence => true

  after_create ->{
    self.delay.update_head unless !self.persisted?
  }

  def update_head
    self.update_attributes( last_head: git.commits("HEAD").first.id )
  end

  def summary
    return "... pending ..." if last_head.blank?
    git.object(last_head).message.split("\n").first
  end

  def path
    path = File.join(Heidi2::Application.config.repositories.root, project._id, _id.to_s + ".git")

    root = File.dirname(path)
    if not File.exists?(root)
      FileUtils.mkdir_p(root)
    end

    return path
  end

  def git
    if File.exists?(path)
      Grit::Repo.new(path)

    else
      clone && git
    end
  end

  def clone
    repo = Grit::Repo.init(path)
    repo.remote_add("origin", uri)
    repo.remote_fetch("origin")
  end

  def fetch
    git.remote_fetch("origin")
  end

  def checkout(commit)
    return false if locked?

    Dir.chdir(path) do
      git.git.checkout({raise: true, b: "build-#{commit[0..6]}"}, commit)
    end
  end

  def lock_file
    File.join(path, ".heidi2.lock")
  end

  def locked?
    File.exists?(lock_file)
  end

  # lock the working tree
  def lock(&block)
    return false if locked?

    File.open(lock_file, File::WRONLY|File::CREAT) do |f|
      f.puts "#{$$}: #{Time.now}"
    end

    yield

    File.unlink(lock_file)
  end

  def commits
    git.commits(default_branch)
  end

  def commit
    git.commit(default_branch)
  end
end
