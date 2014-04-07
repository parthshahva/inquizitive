require 'sinatra'
enable :sessions
require_relative 'lib/inquizitive.rb'

configure do, :group => :production
  DataMapper.setup(:default, ENV['DATABASE_URL'])
end

get '/' do
"Test"
end
