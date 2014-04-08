# require 'dm-core'
# require 'dm-migrations'
# require 'dm-constraints'
require 'data_mapper'

class User
  include DataMapper::Resource
  property :id, Serial
  property :username, String, :unique => true, :required => true
  property :password, String, :length => 8..20, :required => true
  property :phone_number, String, :unique => true, :length => 10, :required => true
  property :last_question_id, Integer
  property :counter, Integer
  has n, :questionset
  has n, :session
end

class Questionset
  include DataMapper::Resource
  property :id, Serial
  property :name, String, :required => true
  belongs_to :user
  has n, :question
end


class Question
  include DataMapper::Resource
  property :id, Serial
  property :text, String, :required => true
  property :answer, String, :required => true
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

