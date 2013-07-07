require 'pp'
require 'celluloid'
require 'celluloid/io'

class BuildWorker
  include Celluloid

  def build(payload)
    instructions = JSON.parse(payload)
    builder      = Heidi2::Builder.new(instructions)
    puts "*** Starting build #{builder.build_object.number}"
    builder.build
    puts "*** Build #{builder.build_object.number} complete"
  end
end

class WorkerPool < Celluloid::SupervisionGroup
  pool BuildWorker, as: :build_worker_pool
end

class WorkerServer
  include Celluloid::IO

  finalizer :shutdown

  def initialize(path)
    puts "*** Starting worker server on #{path}"
    @path = path

    # Since we included Celluloid::IO, we're actually making a
    # Celluloid::IO::TCPServer here
    @server = UNIXServer.new("#{@path}")

    # start a worker pool
    WorkerPool.run!
  end

  def shutdown
    @server.close if @server
    File.unlink(@path)
  end

  def run
    loop { async.handle_connection @server.accept }
  end

  def handle_connection(socket)
    payload = ""
    begin
      loop { payload += socket.readpartial(1024) }
    rescue EOFError
      socket.close
    end

    Celluloid::Actor[:build_worker_pool].build(payload)
  end
end

socket_path = Rails.root.join("tmp", "sockets", "worker.socket")
server = WorkerServer.new(socket_path)
server.run

END {
  File.unlink socket_path
}