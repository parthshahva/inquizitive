require 'sinatra'
enable :sessions
require_relative 'lib/inquizitive.rb'

set :bind, "0.0.0.0"

configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'])
end

get '/' do
  erb :index
end

post '/sign-in' do

end

get '/sign-up' do
  erb :"sign-up"
end
