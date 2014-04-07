require 'dm-core'
require 'dm-migrations'
require 'dm-constraints'

module MBP

class Question
  include DataMapper::Resource
  property :id, Serial
  property :text, String
  property :answer, String
  belongs_to :QuestionSet
end
DataMapper.finalize
class Questionset
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  belongs_to :User
  has n, :Question
end
DataMapper.finalize
class Response
  include DataMapper::Resource
  property :id, Serial
  property :correct, Boolean
  belongs_to :Question
  belongs_to :User
end
DataMapper.finalize
class Session
  include DataMapper::Resource
  property :id, Serial
  belongs_to :User
end
DataMapper.finalize
class User
  include DataMapper::Resource
  property :id, Serial
  property :username, String
  property :password, String
  property :phone_number, String
  property :last_question_id, Integer
  has n, :QuestionSet
  has n, :Session
end
DataMapper.finalize
end
