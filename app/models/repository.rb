require 'fileutils'
require 'grit'

class Repository
  include Mongoid::Document

  field :name, type: String
  field :uri, type: String
  field :default_branch, type: String, default: "origin/develop"
  field :build_head, type: String
  field :build_environment, type: Hash, default: {}

  embedded_in :project
  embeds_many :build_instructions
  embeds_many :builds

  validates :name, :uri, :presence => true

  after_create ->{
    self.delay.guess_build_instructions
  }

  def status
    builds.any? ? builds.last.status : "pending"
  end

  def update_head
    self.update_attributes( build_head: git.commits("HEAD").first.id )
  end

  def guess_build_instructions
    self.fetch
    self.lock do
      self.checkout(self.commit.id)

      if File.exists?(File.join(self.path, "Gemfile"))
        build_instructions.create( script: "bundle install --deployment --binstubs --without development" )
      end

      if File.exists?(File.join(self.path, "Rakefile"))
        build_instructions.create( script: "./bin/rake" )
      end

      if File.exists?(File.join(self.path, "spec"))
        build_instructions.create( script: "./bin/rspec --color -f d spec/" )
      end
    end
  end


  def summary
    return "... pending ..." if build_head.blank?
    git.object(build_head).message.split("\n").first
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

  def checkout(commit=self.commit)
    if !locked?
      warn "You do not have the lock"
      return false
    end

    commit = commit.id if commit.is_a?(Grit::Commit)

    branch_name = "build-#{commit[0..6]}"
    return true if Grit::Head.current(self.git).name == branch_name

    if self.git.branches.any? { |b| b.name == branch_name }
      git.git.checkout({raise: true}, branch_name)
    else
      Dir.chdir(path) do
        git.git.checkout({raise: true, b: branch_name}, commit)
      end
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

  rescue => ex
    Rails.logger.fatal "Error in lock-block: #{ex.class}: #{ex.message}"
    Rails.logger.debug "\t#{ex.backtrace.join("\n\t")}"

  ensure
    File.unlink(lock_file)

  end

  def commits
    git.commits(default_branch)
  end

  def commit
    git.commit(default_branch) || git.commit("HEAD") || git.commit("FETCH_HEAD")
  end

  def build(commit=self.commit, blocking=false)
    socket_path = Rails.root.join("tmp", "sockets", "worker.socket")

    commit = commit.id if commit.is_a?(Grit::Commit)

    if !File.exists? socket_path
      raise "There is no worker hearing on #{socket_path}"
    end

    number = project.inc(:build_number, 1);
    build  = builds.create( number: number, commit: commit )

    instructions = {
      project: project.id, repository: self.id, build: build.id
    }.to_json

    socket = Celluloid::IO::UNIXSocket.open("#{socket_path}")
    socket.syswrite(instructions)
    socket.close
  end

  def build_environment_text
    build_environment.collect { |k,v| "#{k}=#{v =~ /\s/ ? %Q{"#{v}"} : v}" }.join("\n")
  rescue
    ""
  end
end
