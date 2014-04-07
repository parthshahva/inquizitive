class RunSMS < UseCase
  def run(inputs)
     user = User.first(phone_number: inputs[:phone_number][2..-1])
     return failure(:user_does_not_exist) if user.nil?
     return failure(:session_not_active) if user.last_question_id.nil?

     question = Question.get(user.last_question_id)
     question_set = Questionset.get(question.questionset_id)
     return failure(:question_set_not_found) if question_set.nil?

     # answer_checker = false
     # answer_checker = true if question.answer.downcase == inputs[:answer].downcase
     response = "incorrect"
     # response = "correct" if answer_checker == true

     questions = Question.all(:question_id => question_set.id)
     # return failure(:no_questions_in_set) if questions == []
     # Response.create(correct: answer_checker, question_id: question.id, user_id: user.id)

     number = questions.count
     current_question_id = rand(1..number)
     current_question = Question.get(current_question_id)
     user.last_question_id = current_question_id
     user.save
     message = current_question.text
     success :message => "You are #{response}. #{message}"
  end
end

