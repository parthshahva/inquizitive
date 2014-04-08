require 'sinatra'
require 'sinatra/contrib'
require 'twilio-ruby'
require 'dotenv'
require 'rotp'
Dotenv.load

enable :sessions
require_relative 'lib/inquizitive.rb'

configure :development do
  DataMapper.setup(:default, "sqlite://#{Dir.pwd}/inquizitive.db")
end

configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'])
  DataMapper.auto_migrate!
end

get '/' do
  erb :index, :layout => :"sign-in-up-layout"
end

post '/sign-in' do
  result = SignIn.run({:username => params[:username], :password => params[:password]})
  if result.success?
    session[:key] = result.session_id
    puts session[:key]
    redirect to ("/home")
  elsif result.error == :user_not_verified
    redirect to ('/register')
  elsif result.error?
    @message = "incorrect username or password"
  end
    erb :index, :layout => :"sign-in-up-layout"
end

get '/sign-out' do
  puts session[:key]
  result = SignOut.run(session_id: session[:key])
  redirect to("/")
end

get '/register' do
  erb :register, :layout => :"sign-in-up-layout"
end

post '/register' do
  @twilio_number = '5122706595'
  @client = Twilio::REST::Client.new ENV['account_sid'], ENV['auth_token']
  @phone_number = params[:phone_number]
  @username = params[:username]
  @password = params[:password]
  user = User.new(:username => params[:username], :password => params[:password], :phone_number => params[:phone_number])
  if User.all(:username => user.username).size == 1
    totp = ROTP::TOTP.new("drawtheowl")
    code = totp.now
    user.code = code
    user.save
    @client.account.sms.messages.create(
    :from => @twilio_number,
    :to => @phone_number,
    :body => "Your verification code is #{code}")
    erb :register, :layout => :"sign-in-up-layout"
  else
    erb :"sign-up", :layout => :"sign-in-up-layout"
  end
end

post '/verification' do
 user = User.first(:phone_number => params[:phone_number])
 @code = params[:code]
 if user.code == @code
    user.verified = true
    user.save
    @message = "Phone number successfully verified. Please sign in."
    redirect to('/')
 else
  @message = "Phone number not verified. Please sign up again."
  erb :"sign-up", :layout => :"sign-in-up-layout"
  end
end

get '/sign-up' do
  erb :"sign-up", :layout => :"sign-in-up-layout"
end

get '/respond' do
  account_sid = ENV['ACCOUNT_SID']
  auth_token = ENV['AUTH_TOKEN']
  result = nil
  if params[:Body].split[0].downcase == "begin"
    result = StartSMS.run(:question_set_name => params[:Body].split[1], :phone_number => params[:From])
  elsif params[:Body].split[0].downcase == "finish"
    result = EndSMS.run(:phone_number => params[:From])
  elsif params[:Body].split[0].downcase == "list"
    result = ListSMS.run(:phone_number => params[:From])
  elsif params[:Body].split[0].downcase == "helpme"
    result = Help.run(:phone_number => params[:From])
  else
    result = RunSMS.run(:answer => params[:Body], :phone_number => params[:From])
  end

  twiml = Twilio::TwiML::Response.new do |r|
    if result.success?
      r.Message "#{result.message}"
    elsif result.error?
      if result.error == :user_does_not_exist
      r.Message "Sorry, no account was found. Visit 'inquizitive.herokuapp.com/sign-up' to create an account."
      elsif result.error == :question_set_not_found
        r.Message "Sorry, the question set was not found. Text 'list' to list all your question sets."
      elsif result.error == :question_sets_notfound
        r.Message "Sorry, no question sets were found. Visit inquizitive.herokuapp.com to create sets."
      elsif result.error == :no_questions_in_set
        r.Message "Sorry, there are no questions in that set. Visit inquizitive.herokuapp.com to add questions."
      elsif result.error == :no_session_in_progress
        r.Message "Sorry, there is no Inquizitive session in progress. Text 'begin' followed by question set name."
      elsif result.error == :session_not_active
        r.Message "Sorry, there is no active session. Text 'begin' followed by question set name."
      end
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


