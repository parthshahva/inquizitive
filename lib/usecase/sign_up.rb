class SignUp < UseCase
  def run(inputs)
    user = User.first(inputs[:username])
    return failure(:username_taken) if user != nil
    return failure(:password_too_short) if inputs[:password].length < 4
    phone_number = inputs[:phone_number].delete("^0-9")

    return failure(:not_a_valid_number) if phone_number.length < 10
    return failure(:phone_number_already_in_use) if User.first(inputs[:phone_number]) != nil

    user = User.create(username: inputs[:username], password: inputs[:password], phone_number: inputs[:phone_number])
    success :user => user
  end
end
