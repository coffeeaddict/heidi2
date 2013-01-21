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
      object.content_type = "text/plain; charset=ansi"

      object
    end
  end

  def append(string)
    string << "\n" unless string =~ /\n\Z/
    document.raw_data ||= ""
    document.raw_data << string
    document.store

    res = FayeClient.publish("/build/#{build._id}", log: :updated)
  end

  def data
    document.raw_data
  end

  def flush
    document.raw_data = ""
    document.store
  end
end
