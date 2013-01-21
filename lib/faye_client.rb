module FayeClient
  class << self
    delegate :publish, :subscribe, to: :client

    def client
      @client ||= setup_client
    end

    def setup_client
      if !EventMachine.reactor_running?
        Thread.new { EM.run }
        sleep 0.1 while !EventMachine.reactor_running?
      end

      Faye::Client.new(Heidi2::Application.config.faye_uri)
    end
  end
end
