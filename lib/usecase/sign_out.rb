class SignOut < UseCase
  def run(inputs)
    session = Session.get(inputs[:session_id])
    return failure(:session_not_found) if session == nil
    sign_out = session.destroy

    sign_out
  end
end
