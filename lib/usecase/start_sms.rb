class StartSMS < UseCase
  def run(inputs)
     user = User.first(:phone_number => inputs[:phone_number][2..-1])
     return failure(:user_does_not_exist) if user.nil?

     question_set = Questionset.first(:name => inputs[:question_set_name], :user_id => user.id)
     return failure(:question_set_not_found) if question_set.nil?

     questions = Question.all(:questionset_id => question_set.id)
     return failure(:no_questions_in_set) if questions.nil?

     number = questions.count - 1
     current_question_id = rand(0..number)
     current_question = Question.get(current_question_id)
     user.last_question_id = current_question_id
     user.save
     message = current_question.text
     success :message => message
  end
end

