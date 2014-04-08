class StartSMS < UseCase
  def run(inputs)
     user = User.first(:phone_number => inputs[:phone_number][2..-1])
     # return failure(:user_does_not_exist) if user.nil?

     question_set = Questionset.first(:name => inputs[:question_set_name], :user_id => user.id)
     # return failure(:question_set_not_found) if question_set.nil?

     questions = Question.all(:questionset_id => question_set.id)
     # return failure(:no_questions_in_set) if questions.size == 0

     number = questions.size - 1
     index = rand(0..number)
     current_question = questions[index]
     user.last_question_id = current_question.id
     user.save
     message = current_question.text
     success :message => message
  end
end

