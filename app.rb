require 'sinatra'
enable :sessions
require_relative 'lib/inquizitive.rb'
set :bind, "0.0.0.0"
configure :development do
  DataMapper.setup(:default, "sqlite://#{Dir.pwd}/inquizitive.db")
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
  @user = User.new(:username => params[:username], :password => params[:password], :phone_number => params[:phone_number].delete("^0-9"))
  # result = SignUp.run({:username => params[:username], :password => params[:password], :phone_number => params[:phone_number]})
  if @user.valid?
    @user.save
    @message = "user created!"
  else
    puts @user.errors.inspect
    # @user.errors.each do |e|
    #   puts e
    # end
    # @message = @user[:messages]

  end
  erb :index
end

get '/create-question' do
  key = session[:key]
  sess = Session.get(session[:key])
  @user = User.get(sess.user_id)
  @sets = Questionset
  erb :"create-question"
end

post '/create-question' do
  erb :"create-question"
end

get '/create-question-set' do
  erb :"create-question-set"
end

post '/create-question-set' do
  erb :"create-question-set"
end

