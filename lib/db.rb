require 'dm-core'
require 'dm-migrations'
require 'dm-constraints'


class User
  include DataMapper::Resource
  property :id, Serial
  property :username, String
  property :password, String
  property :phone_number, String
  property :last_question_id, Integer
  has n, :questionset
  has n, :session
end
DataMapper.finalize
class Questionset
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  belongs_to :user
  has n, :question
end
DataMapper.finalize

class Question
  include DataMapper::Resource
  property :id, Serial
  property :text, String
  property :answer, String
  belongs_to :questionset
end
DataMapper.finalize

class Response
  include DataMapper::Resource
  property :id, Serial
  property :correct, Boolean
  belongs_to :question
  belongs_to :user
end
DataMapper.finalize

class Session
  include DataMapper::Resource
  property :id, Serial
  belongs_to :user
end
DataMapper.finalize

