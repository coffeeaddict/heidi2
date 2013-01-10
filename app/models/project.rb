class Project
  include Mongoid::Document

  field :name, type: String
  field :_id, type: String, default: ->{ name.underscore.gsub(/[^\p{Word}]+/,'-') rescue nil }
  field :status, type: String

  embeds_many :repositories

  validates :name,
    presence: true

  validates :_id,
    uniqueness: true

  validates :status,
    presence: true,
    inclusion: { in: %w[pending passing failing building] }

  def builds
    repositories.collect(&:builds)
  end
end
