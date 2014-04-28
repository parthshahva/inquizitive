class RecoverPassword < UseCase
  def run(inputs)
    user = User.first(username: inputs[:username])
    return failure(:username_not_found) if user==nil
    return failure(:user_not_verified) if user.verified == false
    return failure(:phone_not_matched) if inputs[:phone_number] != user.phone_number
    success :user => user
  end
end
