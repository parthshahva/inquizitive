require 'spec_helper'

describe SignOut do
  it 'signs a user out' do
    user = User.create(username: "Moe", password: "mypassword", phone_number: "4693230314")
    sign_in = Session.create(user_id: user.id)
    result = SignOut.run(session_id: sign_in.id)

    expect(result).to be_true
    expect(Session.first(user_id: user.id)).to eq(nil)

  end
end
