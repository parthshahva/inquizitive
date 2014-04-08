class Help < UseCase
  def run(inputs)
     user = User.first(phone_number: inputs[:phone_number][2..-1])
     return failure(:user_does_not_exist) if user.nil?
     message = "'List' to get question set names. 'Begin' + qset name to start session. 'Finish' to end session."

     success :message => message
  end
end
