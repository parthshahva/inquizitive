# class CreateQuestion < UseCase
#   def run(inputs)
#       session = Session.get(inputs[:session_id])
#       return failure(:session_not_found) if session == nil
#       question_set = Questionset.get(inputs[:question_set_id])
#       return failure(:question_set_not_found) if question_set == nil
#       question = Question.create(questionset: inputs[:question_set_id], text: inputs[:text], answer: inputs[:answer])

#       success :question => question, :question_set => question_set
#   end
# end
