class StartSMS < UseCase
  def run(inputs)
     user = User.first(phone_number: inputs[:phone_number][2..-1])
     return failure(:user_does_not_exist) if user.nil?
     return failure(:no_session_in_progress) if user.last_question_id == nil
     user.last_question_id = nil
     user.save
     message = "Inquizitive successfuly ended"
     success :message => message
  end
end
