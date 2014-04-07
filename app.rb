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
result = SignIn.run(:username => params[:username], :password => params[:password])
if result.success?
  @message = "It worked #{result.user.username}"
  sessions[:session_id] = result.session_id
else
  @message = "Try Again"
end
end
erb :index

get '/sign-up' do
  result = SignUp.run()
  erb :"sign-up"
end
