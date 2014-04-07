class RunSMS < UseCase
  def run(inputs)
     user = User.first(phone_number: inputs[:phone_number])
     return failure(:user_does_not_exist) if user.nil?
     return failure(:session_not_active) if user.last_question_id.nil?

     question = Question.get(user.last_question_id)
     question_set = Questionset.get(question.questionset_id)
     return failure(:question_set_not_found) if question_set.nil?

     answer_checker = "incorrect"
     answer_checker = "correct" if question.answer.downcase == inputs[:answer].downcase
     if answer_checker == "incorrect"
        response_boolean = false
     elsif answer_checker == "correct"
        response_boolean = true
     end

     questions = Question.all(:question_id => question_set.id)
     return failure(:no_questions_in_set) if questions.nil?
     response = Response.create(correct: response_boolean, question_id: question.id, user_id: user.id)

     number = questions.count - 1
     current_question_id = rand(0..number)
     current_question = Question.get(current_question_id)
     user.last_question_id = current_question_id
     user.save
     message = current_question.text
     success :message => "You are #{answer_checker}. #{message}"
  end
end
