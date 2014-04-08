class Statistics < UseCase
  def run(inputs)
    user = User.first(user_id: inputs[:user_id])
    return failure(:username_not_found) if user==nil




    success :user => user
  end
end
