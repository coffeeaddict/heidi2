require 'pp'
EM.run {
  FayeClient.subscribe('/build/project') do |message|
    pp message

    project = Project.find(message['project'])
    repo = project.repositories.find(message['repo'])

    repo.build(message['commit'])
  end
}
