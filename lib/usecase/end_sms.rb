class StartSMS < UseCase
  def run(inputs)
     user = User.first(phone_number: inputs[:phone_number])
     return failure(:user_does_not_exist) if user.nil?
     return failure(:no_session_in_progress) if user.last_question_id == nil
     user.last_question_id = nil
     user.save
     message_test = user.last_question_id
     message = "Inquizitive successfuly ended" if message_test.nil?
     success :message => message
  end
end
