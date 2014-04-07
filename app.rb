require 'sinatra'
enable :sessions
require_relative 'lib/inquizitive.rb'

configure :development do
  DataMapper.setup(:default, "sqlite://#{DIR.pwd}/inquizitive.db")
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
    session[:session_id] = result.session_id
  else
    @message = "#{result.error}"
  end
  erb :index
end

get '/sign-up' do
  erb :"sign-up"
end

post '/sign-up' do
  @user = User.new(:username => params[:username], :password => params[:password], :phone_number => params[:phone_number])
  # result = SignUp.run({:username => params[:username], :password => params[:password], :phone_number => params[:phone_number]})
  if @user.valid?
    @user.save
  else
    @user.errors[:message]
  end
  erb :index
end
