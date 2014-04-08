require 'sinatra'
require 'twilio-ruby'
require 'dotenv'
Dotenv.load

enable :sessions
require_relative 'lib/inquizitive.rb'

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

    session[:key] = result.session_id
    redirect to ("/home")
  else
    @message = "#{result.error}"
  end
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


get '/respond' do
  account_sid = ENV['ACCOUNT_SID']
  auth_token = ENV['AUTH_TOKEN']
  result = nil
  if params[:Body].split[0].downcase == "begin"
    result = StartSMS.run(:question_set_name => params[:Body].split[1], :phone_number => params[:From])
  elsif params[:Body].split[0].downcase == "finish"
    result = EndSMS.run(:phone_number => params[:From])
  else
    result = RunSMS.run(:answer => params[:Body], :phone_number => params[:From])
  end

  twiml = Twilio::TwiML::Response.new do |r|
    if result.success?
      r.Message "#{result.message}"
    elsif result.error?
      if result.error == :user_does_not_exist
      r.Message "Sorry, user does not exist"
      elsif result.error == :question_set_not_found
        r.Message "Sorry, there is no question set found under your name"
      elsif result.error == :no_questions_in_set
        r.Message "Sorry, there are no questions in that set"
      elsif result.error == :no_session_in_progress
        r.Message "Sorry, there is no Inquizitive session in progress"
      elsif result.error == :session_not_active
        r.Message "Sorry, there is no active session. Text 'Start' followed by the name of the question set"
      end
    else
      r.Message "IDK bro"
    end
  end
  twiml.text
end








get "/home" do
  key = session[:key]
  sess = Session.get(session[:key])
  @user = User.get(sess.user_id)
  #array of question_set objects
  @question_sets = Questionset.all(:user_id => @user.id)
  @all_questions = Hash.new

  @question_sets.map do |qset|
    questions = Question.all(:questionset_id => qset.id)
    @all_questions[qset.id] = questions
  end

  puts @all_questions.inspect
  erb :home
end

post "/create-qset" do
  key = session[:key].to_i
  sess = Session.get(key)
  user = User.get(sess.user_id)
  question_set = Questionset.new(:name => params[:qset_name], :user_id => user.id)


  if question_set.save
    redirect to("/home")
  else
    "this didn't work"
  end

end

post '/create-question' do
  key = session[:key]
  sess = Session.get(session[:key])
  user = User.get(sess.user_id)
  #need use case question set does not exist
  question_set = Questionset.first(:name => params[:question_set])
  #need use cases for each parameter not existing
  question = Question.new(:text => params[:question_text], :answer => params[:answer], :questionset_id => question_set.id)

  if question.save
    puts question
    redirect to ("/home")
  else
    "this did not work"
  end
end


