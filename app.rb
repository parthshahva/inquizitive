require 'sinatra'
require 'twilio-ruby'
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


get '/respond' do
  account_sid = 'AC79afc966ef3d304699eadbd31e7b066d'
  auth_token = '5de6b5fb8c98a947042ca99d0050c5c8'
  result = nil
  if params[:Body].split[0].downcase == "begin"
    result = StartSMS.run(:question_set_name => params[:Body].split[1], :phone_number => params[:From])
  # elsif params[:Body].split[0].downcase == "stop"
  #   result = EndSMS.run(:phone_number => params[:From])
  # else
  #   result = RunSMS.run(:answer => params[:Body], :phone_number => params[:From])
  end

  twiml = Twilio::TwiML::Response.new do |r|
    if result.success?
      r.Message "#{result.message}"
    elsif result.error?
      if result.error == :user_does_not_exist
      r.Message "Sorry, user does not exist"
      elsif result.error == :question_set_not_found
        r.Message "Sorry, there is not question set found under your name #{params[:Body]}"
      elsif result.error == :no_questions_in_set
        r.Message "Sorry, there are no questions in that set"
      elsif result.error == :no_session_in_progress
        r.Message "Sorry, there is no Inquizitive session in progress"
      elsif result.error == :session_not_active
        r.Message "Sorry, there is no active session. Text 'Start' followed by the name of the question set"
      end
    end
  end
  twiml.text
end







