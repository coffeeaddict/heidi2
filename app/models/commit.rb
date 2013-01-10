class Commit
  include Mongoid::Document
  
  field :sha, type: String
end