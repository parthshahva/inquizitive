# require 'dm-core'
# require 'dm-migrations'
# require 'dm-constraints'
require 'data_mapper'

class User
  include DataMapper::Resource
  property :id, Serial
  property :username, String, :unique => true
  property :password, String, :length => 8..20
  property :phone_number, String, :unique => true, :length => 10
  property :last_question_id, Integer
  has n, :questionset
  has n, :session
end

class Questionset
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  belongs_to :user
  has n, :question
end


class Question
  include DataMapper::Resource
  property :id, Serial
  property :text, String
  property :answer, String
  belongs_to :questionset
end


class Response
  include DataMapper::Resource
  property :id, Serial
  property :correct, Boolean
  belongs_to :question
  belongs_to :user
end

class Session
  include DataMapper::Resource
  property :id, Serial
  belongs_to :user
end
DataMapper.finalize

