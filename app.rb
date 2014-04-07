require 'sinatra'
enable :sessions
require_relative 'lib/inquizitive.rb'

configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'])
end

get '/' do
"Test"
end
