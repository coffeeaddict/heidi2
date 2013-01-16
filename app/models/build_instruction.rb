class BuildInstruction
  include Mongoid::Document

  field :script, type: String
  field :blocking, type: Boolean, default: true

  embedded_in :repository

  def blocking?
    !!blocking
  end
end
