require 'sinatra'
require 'sinatra/contrib'
require 'rotp'
require 'data_mapper'
require 'JSON'
enable :sessions
require_relative 'lib/inquizitive.rb'

# DataMapper.setup(:default, "sqlite://#{Dir.pwd}/inquizitive.db")
# DataMapper.auto_upgrade!
# DataMapper.auto_migrate!
# user = User.create(:username => "parth", :password => "password", :verified => true, :phone_number => '7576507728')
# question_set = Questionset.create(:name => "biology", :user_id => 1)
# question_set_two = Questionset.create(:name => "chemistry", :user_id => 1)
# question = Question.create(:text => "2+2", :answer => "4", :questionset_id => question_set.id)
# question_two = Question.create(:text => "3+5", :answer => "8", :questionset_id => question_set.id)
# Response.create(:correct => true, :question_id => question.id, :user_id => user.id, :questionset_id => question_set.id, :time => Time.now)
# Response.create(:correct => true, :question_id => question.id, :user_id => user.id, :questionset_id => question_set.id, :time => Time.now)
# Response.create(:correct => true, :question_id => question_two.id, :user_id => user.id, :questionset_id => question_two.questionset_id, :time => Time.now)

configure :production do
  DataMapper.setup(:default, ENV['DATABASE_URL'])
  DataMapper.auto_upgrade!
end

get '/' do
  erb :index, :layout => :"sign-in-up-layout"
end

get '/start' do
  key = session[:key]
  sess = Session.get(session[:key])
  @user = User.get(sess.user_id)
  SendText.run(:phone_number => @user.phone_number, :body => "Text 'begin' + the question set name to start! Type list to view your question sets.")
  @textsent = "yes"
  erb :home
end

get '/online' do
  key = session[:key]
  sess = Session.get(session[:key])
  @user = User.get(sess.user_id)
  @question_sets = Questionset.all(:user_id => @user.id)
  @all_questions = Hash.new
  @correct = Hash.new
  @question_sets.map do |qset|
    questions = Question.all(:questionset_id => qset.id)
    @all_questions[qset.id] = questions
    good = Response.all(:questionset_id => qset.id, :correct => true).count
    bad = Response.all(:questionset_id => qset.id, :correct => false).count
    @correct[qset.id] = good.to_f/(good + bad)*100
    @correct[qset.id] = @correct[qset.id].round(1)
    @correct[qset.id] = "Not Started" if Response.all(:questionset_id => qset.id).count == 0
  end
  erb :online
end

post '/answeronline' do
  question_set = Questionset.first(:id => params[:questionsetid].to_i)
  question = Question.first(:id => params[:questionid].to_i)
  user = User.first(:id => question_set.user_id)
  result = UseOnline.run(:phone_number => user.phone_number, :questionset_id => question_set.id, :question_id => question.id, :answer => params[:answer])
  good = Response.all(:questionset_id => question_set.id, :correct => true).count
  bad = Response.all(:questionset_id => question_set.id, :correct => false).count
  percentage = good.to_f/(good + bad)*100
  percentage = percentage.round(1)
  @correct = result.correct
  @question = result.current_question
  @object = {:correct => @correct, :question => @question.text, :answer => @question.answer, :questionset_id => question_set.id, :question_id => @question.id, :percentage => percentage}

  content_type :json
  @object.to_json
end

get '/create' do
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
  erb :create
end

get '/recovery' do
  erb :recovery, :layout => :"sign-in-up-layout"
end

post '/recovery' do
  result = RecoverPassword.run({:username => params[:username], :phone_number => params[:phonenumber]})
  user = result.user
  if result.success?
    @phone_number = params[:phonenumber]
    SendText.run(:phone_number => @phone_number, :body => "Your password is #{user.password}")
    erb :index, :layout => :"sign-in-up-layout"
  else
    @message = "We could not find matching credentials"
  end
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
  @phone_number = params[:phone_number]
  @username = params[:username]
  @password = params[:password]
  user = User.new(:username => params[:username], :password => params[:password], :phone_number => params[:phone_number])
  if User.all(:username => user.username).size == 0 && User.all(:phone_number => user.phone_number).size == 0
    totp = ROTP::TOTP.new("drawtheowl")
    code = totp.now
    user.code = code
    user.save
    SendText.run(:phone_number => @phone_number, :body => "Your verification code is #{code}")
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

  if result.success?
    SendText.run(:phone_number => params[:From], :body => "#{result.message}")
  elsif result.error?
    if result.error == :user_does_not_exist
      SendText.run(:phone_number => params[:From], :body => "Sorry, no account was found. Visit 'inquizitive.herokuapp.com/sign-up' to create an account.")
    elsif result.error == :question_set_not_found
      SendText.run(:phone_number => params[:From], :body => "Sorry, the question set was not found. Text 'list' to list all your question sets.")
    elsif result.error == :no_questions_in_set
      SendText.run(:phone_number => params[:From], :body => "Sorry, there are no questions in that set. Visit inquizitive.herokuapp.com to add questions.")
    elsif result.error == :no_session_in_progress
      SendText.run(:phone_number => params[:From], :body => "Sorry, there is no Inquizitive session in progress. Text 'begin' followed by question set name.")
    elsif result.error == :session_not_active
      SendText.run(:phone_number => params[:From], :body => "Sorry, there is no active session. Text 'begin' followed by question set name.")
    end
  end
end

get "/home" do
  key = session[:key]
  sess = Session.get(session[:key])
  @user = User.get(sess.user_id)
  erb :home
end

post "/create-qset" do
  key = session[:key].to_i
  sess = Session.get(key)
  user = User.get(sess.user_id)
  question_set = Questionset.new(:name => params[:qset_name], :user_id => user.id)


  if question_set.save
    session[:message] = "Question set '#{question_set.name}' created!"
    redirect to("/create")
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
    redirect to ("/create")
  else
    "this did not work"
  end
end

get '/statistics' do
  key = session[:key]
  sess = Session.get(session[:key])
  @user = User.get(sess.user_id)
  @all_responses = Response.all(:user_id => @user.id)

  # Create a hash with key qsetid, value { correct: count, total_answered: count}
  @history = {}
  @all_responses.each do |response|
    @history[response.questionset_id] ||= { total: 0, correct: 0 }
    @history[response.questionset_id][:total] += 1
    @history[response.questionset_id][:correct] += 1 if response.correct
  end
  erb :statistics
end


