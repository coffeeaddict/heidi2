module Heidi2
  class Builder
    def initialize(repo)
      @repo = repo
    end

    def faye
      @faye ||= Faye::Client.new("http://localhost:8000/faye")
    end

    def build(commit)
      return if @repo.locked?
      @repo.lock do
        @repo.checkout(commit)

        if @repo.builds.where( commit: commit ).any?
          @build = @repo.builds.find_by( commit: commit )
          if @build.status == 'building'
            Rails.logger.error "The build is already building"
            return
          end
          @build.log.flush
          @build.update_attributes(status: 'building')

        else
          @build = @repo.builds.create( commit: commit, status: 'building' )
          @build.create_log
        end

        faye.publish("/#{@repo.project._id}/#{@repo._id}", new_build: @build._id.to_s)

        @repo.build_instructions.each do |instruction|
          execute(instruction)
          break if @build.status == 'failed'
        end
      end

      @build.status = 'passed' unless @build.status == 'failed'
      @build.save

      return @build
    end

    def execute(instructions)
      start = Time.now
      env = {
        'HEIDI2_DIR'          => @build.repository.path,
        'HEIDI2_BUILD_COMMIT' => @build.commit,
        'HEIDI2_BRANCH'       => @build.repository.default_branch,

        'RUBYOPT'         => nil,
        'BUNDLE_BIN_PAHT' => nil,
        'BUNDLE_GEMFILE'  => nil,
        'GEM_HOME'        => nil,
        'GEM_PATH'        => nil,
      }

      shell = SimpleShell.new(@build.repository.path, env)
      shell.stdout_handler = ->(line) {
        @build.log.append(line)
      }
      shell.stderr_handler = ->(line) {
        msg = "[ERR] " + line
        msg = "\e[1;31m#{msg}\e[0m"
        @build.log.append(msg)
      }

      @build.log.append("\e[1m% #{instructions.script}\e[0m")
      res = shell.do(instructions.script)

      if res.S?.to_i != 0
        @build.status = "failed"
      end
    end

  end # Builder
end # Heidi2



