require 'spec_helper'

describe RunSMS do
  it 'exists' do
    expect(RunSMS).to be_a(Class)
  end

  it 'expecting questionable behavior' do
  @user = User.create(username: "Moe", password: "mypassword", phone_number: "4693230314")
# create question set
  @question_set = Questionset.create(:name => "math", :user_id => @user.id)
# create question set
 @question_set_two = Questionset.create(:name => "biology", :user_id => @user.id)
# create 5 question in set 1
  @question_one = Question.create(:questionset_id => @question_set.id, :text => "1 + 1", :answer => "2")
  @question_two = Question.create(:questionset_id => @question_set.id, :text => "1 + 2", :answer => "3")
  @question_three = Question.create(:questionset_id => @question_set.id, :text => "1 + 3", :answer => "4")
  @question_four = Question.create(:questionset_id => @question_set.id, :text => "1 + 4", :answer => "5")
  @question_five = Question.create(:questionset_id => @question_set.id, :text => "1 + 5", :answer => "6")
# create 5 questions in set 2
  @question_six = Question.create(:questionset_id => @question_set_two.id, :text => "1 - 1", :answer => "0")
  @question_seven = Question.create(:questionset_id => @question_set_two.id, :text => "1 - 2", :answer => "-1")
  @question_eight = Question.create(:questionset_id => @question_set_two.id, :text => "1 - 3", :answer => "-2")
  @question_nine = Question.create(:questionset_id => @question_set_two.id, :text => "1 - 4", :answer => "-3")
  @question_ten = Question.create(:questionset_id => @question_set_two.id, :text => "1 - 5", :answer => "-4")

  @user.last_question_id = @question_one.id
  @user.save

  result = RunSMS.run(:answer => "2", :phone_number => "+1#{@user.phone_number}")
  expect(result.message).to be_a(String)
  @user.last_question_id = @question_nine.id
  @user.save
  result2 = RunSMS.run(:answer => "-3", :phone_number => "+1#{@user.phone_number}")
  expect(result2.message).to be_a(String)
  @user.last_question_id = @question_seven.id
  @user.save
  result3 = RunSMS.run(:answer => "-1", :phone_number => "+1#{@user.phone_number}")
  expect(result3.message).to be_a(String)

  @question = Question.first(:id => @user.last_question_id)
  @question_set_name = Questionset.first(:id => @question.questionset_id).name
  expect(@question_set_name).to eq("biology")
  end

end
