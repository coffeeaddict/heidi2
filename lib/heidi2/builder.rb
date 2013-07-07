module Heidi2
  class Builder
    def build_object
      @build
    end

    def initialize(instructions)
      @project = Project.find(instructions['project'])
      @repo    = @project.repositories.find(instructions['repository'])
      @build   = @repo.builds.find(instructions['build'])
    end

    def build(commit=@build.commit)
      return if @repo.locked?
      return if %w[skipped passed].include?(@build.status)

      @repo.lock do
        if @build.status != 'pending'
          if @build.status == 'building'
            Rails.logger.error "The build is already building"
            return
          end
          @build.log.flush
          @build.update_attributes(status: 'pending')
        end

        @event = BuildEvent.create(
          project: @project,
          repository_id: @repo._id,
          build_id: @build._id,
          message: "Started build"
        )

        if @repo.git.commit(commit).nil?
          @event.set_message( "Fetching latest changes" )
          @repo.fetch
        end

        if @repo.git.commit(commit).nil?
          @event.set_message( "Commit #{commit} is unreachable." )
          @build.update_attributes( status: "failed" )

          return
        end

        if @repo.git.commit(commit).message =~ /\[(skip ci|ci skip)\]/
          @build.update_attributes(status: "skipped")
          @event.set_message( "Commit #{commit} wants to be skipped." )

          return
        end

        @repo.update_attributes( build_head: commit )
        @event.set_message("Creating build checkout")
        @repo.checkout(commit)

        @build.update_attributes(status: "building")

        @repo.build_instructions.each do |instruction|
          execute(instruction)
          break if @build.status == 'failed'
        end
      end

      if @build.status == 'building'
        @build.update_attributes( status: 'passed' )
        @event.set_message('')
      end

      return @build
    rescue => ex
      @event.set_message("Build error; #{ex.class}: #{ex.message}") if @event
      @build.update_attributes( status: 'failed' ) if @build

    end

    def execute(instructions)
      start = Time.now
      env = {
        'HEIDI2_DIR'          => @build.repository.path,
        'HEIDI2_BUILD_COMMIT' => @build.commit,
        'HEIDI2_BRANCH'       => @build.repository.default_branch,

        'RUBYOPT'         => nil,
        'BUNDLE_BIN_PATH' => nil,
        'BUNDLE_GEMFILE'  => nil,
        'GEM_HOME'        => nil,
        'GEM_PATH'        => nil,
      }.merge(@build.repository.build_environment || {})

      if ( @repo.build_instructions.index(instructions) == 0 )
        @build.log.append(
          "\e[33m" +
          env.collect { |k,v| "-- #{k}=#{v}" }.join("\n") +
          "\e[0m" )
      end

      shell = SimpleShell.new(@build.repository.path, env)
      shell.stdout_handler = ->(line) {
        @build.log.append(line)
      }
      shell.stderr_handler = ->(line) {
        msg = "[stderr] " + line.chomp
        msg = "\e[1;31m#{msg}\e[0m"
        @build.log.append(msg)
      }

      @build.log.append("\e[1m% #{instructions.script}\e[0m")
      @event.set_message("Started #{instructions.script}")
      res = shell.do(instructions.script)

      if res.S?.to_i != 0
        @build.update_attributes( status: "failed" )
        @build.log.append("\e[1;31m-- Failed with exit status #{res.S?.to_i}\e[0m")
        @event.set_message("Failed on #{instructions.script}")
      end

      @build.log.append("\e[33m-- Took #{"%.2fs" % (Time.now - start)}\e[0m")
    rescue => ex
      msg = "\e[1;31m[FATAL] #{ex.class}: #{ex.message}\e[0m"
      @build.log.append(msg)
    end

  end # Builder
end # Heidi2
