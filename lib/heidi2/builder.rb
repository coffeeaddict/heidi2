module Heidi2
  class Builder
    def initialize(repo)
      @repo = repo
    end

    def build(commit)
      return unless @repo.locked?
      @repo.checkout(commit)

      @build = @repo.builds.create( commit: commit, status: 'building' )
      @build.create_log

      @repo.build_instructions.each do |instruction|
        if instruction.blocking?
          execute(instruction)
        else
          Thread.new { execute(instruction) }
        end
      end

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
      shell.stdout_handler ->(line) {
        @build.log.append(line)
      }
      shell.stderr.handler ->(line) {
        @build.log.append("[ERR] " + line)
      }

      res = shell.do(instructions.script)

      if res.S?.to_i != 0
        @build.status = "failing"
      end
    end

  end # Builder
end # Heidi2



