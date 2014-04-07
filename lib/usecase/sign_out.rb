class SignOut < UseCase
  def run(inputs)
    session = Session.first(session_id: inputs[:session_id])
    return failure(:session_not_found) if session == nil
    session.destroy

    success
  end
end
