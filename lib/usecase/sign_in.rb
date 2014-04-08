class SignIn < UseCase
  def run(inputs)
    user = User.first(username: inputs[:username])
    return failure(:username_not_found) if user==nil
    return failure(:password_not_correct) if user.password != inputs[:password]
    return failure(:user_not_verified) if user.verified == false
    session = Session.create(:user_id => user.id)

    success :session_id => session.id, :user => user
  end
end
