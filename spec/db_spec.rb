require 'spec_helper'

describe 'User' do
  it 'exists' do
    expect(User).to be_a(Class)
  end
  describe '.initialize' do
    it 'requires a username, password and phone number' do
      user = User.create(username: "Moe", password: "mypassword", phone_number: "4693230314")

      retrieved_user = User.first(username: "Moe")

      expect(retrieved_user.phone_number).to eq("4693230314")
    end
  end
end
