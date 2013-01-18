class Project
  include Mongoid::Document

  field :name, type: String
  field :_id, type: String, default: ->{ name.underscore.gsub(/[^\p{Word}]+/,'-') rescue nil }
  field :status, type: String, default: "pending"

  embeds_many :repositories

  validates :name,
    presence: true

  validates :_id,
    uniqueness: true

  validates :status,
    presence: true,
    inclusion: { in: %w[pending passed failed building] }

  def builds
    repositories.collect(&:builds).flatten
  end

  def build!
    repositories.each do |repo|
      repo.build
    end
  end

  def determine_status
    status = if repositories.any? { |r| r.status == "building" }
      "building"
    elsif repositories.any? { |r| r.status == "failed" }
      "failed"
    else
      "passed"
    end

    update_attributes( status: status )
  end

end
