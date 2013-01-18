EM.run {
  client = Faye::Client.new('http://localhost:8000/faye')

  client.subscribe('/build/project') do |message|
    project = Project.find(message[:project])
    repo = project.repositories.find(message[:repo])

    repo.build(message[:commit])
  end
}
