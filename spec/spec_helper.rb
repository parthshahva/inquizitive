require_relative '../lib/inquizitive.rb'
require 'rack/test'

RSpec.configure do |config|
  config.include Rack::Test::Methods
  DataMapper::setup(:default, "sqlite://#{Dir.pwd}/inquizitive.db")

  DataMapper.finalize
  User.auto_migrate!
  Questionset.auto_migrate!
  Question.auto_migrate!
  Response.auto_migrate!
  Session.auto_migrate!

end

def app
  Sinatra::Application
end
