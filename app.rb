require 'sinatra'
enable :sessions
require_relative 'lib/inquizitive.rb'

configure :development do
  DataMapper.setup(:default, 'sqlite://inquizitive.db')
end

configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'])
end

get '/' do
  erb :index
end

post '/sign-in' do
  result = SignIn.run({:username => params[:username], :password => params[:password]})
  if result.success?
    @message = "It worked #{result.user.username}"
    sessions[:session_id] = result.session_id
  else
    @message = "Try Again"
  end
  erb :index
end

get '/sign-up' do
  erb :"sign-up"
end

post '/sign-up' do
  result = SignUp.run({:username => params[:username], :password => params[:password], :phone_number => params[:phone_number]})
  if result.success?
    @message = "Nice, #{result.user.username}. You have been created"
  else
    @message = "Seems to have failed"
  end
  erb :index
end
