module MBP
  class SignOut < UseCase
    def run(inputs)
      @db = MBP.db
      session = @db.get_session(inputs[:session_id])
      return failure(:session_not_found) if session == nil
      @db.delete_session(inputs[:session_id])
      # Return a success with relevant data
      success
    end
  end
end
