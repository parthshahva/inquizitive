class SignUp < UseCase
  def run(inputs)
    user = User.first(inputs[:username])
    return failure(:username_taken) if user.username == inputs[:username]
    return failure(:password_too_short) if inputs[:password].length < 4
    phone_number = inputs[:phone_number].delete("^0-9")

    return failure(:not_a_valid_number) if phone_number.length < 10
    return failure(:phone_number_already_in_use) if User.first(inputs[:phone_number]).phone_number == inputs[:phone_number]

    user = User.create(username: inputs[:username], password: inputs[:password], phone_number: "+1#{inputs[:phone_number]}", correct_counter: 0, longest_correct_streak: 0)
    success :user => user
  end
end
