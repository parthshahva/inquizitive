class SignUp < UseCase
  def run(inputs)
    @db = MBP.db
    user = @db.get_user_from_username(inputs[:username])
    return failure(:username_taken) if user != nil

    return failure(:password_too_short) if inputs[:password].length < 4

    phone_number = inputs[:phone_number].delete("^0-9")

    return failure(:not_a_valid_number) if phone_number.length < 10

    return failure(:phone_number_already_in_use) if @db.get_user_from_phone_number(inputs[:phone_number]) != nil

    user = @db.create_user(inputs[:username], inputs[:password], inputs[:phone_number])
    success :user => user
  end
end
