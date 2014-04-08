class ListSMS < UseCase
  def run(inputs)
     user = User.first(phone_number: inputs[:phone_number][2..-1])
     return failure(:user_does_not_exist) if user.nil?
     question_sets = Questionsets.all(:user_id => user.id)
     return failure(:question_sets_not_found) if question_sets == []

     message = ""
     question_sets.each do |x|
         message << x.name + ". "
     end

     success :message => message
  end
end
