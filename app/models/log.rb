class Log
  include Mongoid::Document

  embedded_in :build

  def document
    (@document && @document.reload) || (@document = fetch_document)
  end

  def fetch_document
    @client ||= Riak::Client.new
    bucket = @client.bucket("heidi2_#{Rails.env}_#{build.repository.project._id}")

    document = begin
      bucket.get("#{_id}.log")
    rescue Riak::HTTPFailedRequest
      object = bucket.new("#{_id}.log")
      object.content_type = "text/plain"

      object
    end
  end

  def append(string)
    string << "\n" unless string =~ /\n\Z/
    document.raw_data ||= ""
    document.raw_data << string
    document.store

    faye.publish("/build/#{_id}", log: :updated)
  end

  def faye
    @faye ||= setup_faye
  end

  def setup_faye
    unless defined? Thin
      Thread.new { EM.run }
      sleep 1
    end

    Faye::Client.new('http://localhost:8000/faye')
  end
end
