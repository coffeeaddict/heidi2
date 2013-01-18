class BuildInstruction
  include Mongoid::Document

  field :script, type: String
  field :blocking, type: Boolean, default: true

  embedded_in :repository

  validates :script,
    presence: true

  def blocking?
    !!blocking
  end
end
