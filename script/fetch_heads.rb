def debug(str)
  return unless Rails.env.development?
  $stderr.puts str
end

EM.run {
  msgs = 0

  Project.all.each do |project|
    debug("Inspecting #{project.name}")

    project.repositories.each do |repo|
      debug("\tFetching #{repo.name}")

      repo.fetch
      unless (head = repo.commit)
        debug("\tNo commit, strange...")
        next
      end

      if head.id != repo.build_head
        if head.message !~ /\[(skip ci|ci skip)\]/
          payload = {
            project: project._id,
            repo:    repo._id.to_s,
            commit:  head.id
          }

          # build it
          msgs += 1
          msg = FayeClient.publish( "/build/project", payload )
          msg.callback do
            msgs -= 1
          end
          msg.errback do
            $stderr.puts "build message undelivered"
            msgs -= 1
          end

          debug("\t\tBuilding #{head.id[0..6]}")
        else
          debug("\t\tSkipping #{head.id[0..6]} per request [#{$1}]")
          repo.update_attributes( build_head: head.id )
        end
      else
        debug("\t\tNothing changed")
      end
    end
  end

  # Wait for all the messages to be cleared
  timer = EventMachine::PeriodicTimer.new(5) do
    if msgs <= 0
      timer.cancel
      EM.stop
    end

    puts "#{Time.now} : Still waiting for #{msgs} messages"
  end
}
