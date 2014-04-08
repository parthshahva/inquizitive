require 'spec_helper'

describe RunSMS do
  it 'exists' do
    expect(RunSMS).to be_a(Class)
  end

  it 'expecting questionable behavior' do
    user = User.create(username: 'dick', password: 'branchtip', phone_number: '4693230314')
    question_set = Questionset.create(name: 'brian', user_id: user.id)

    question1 = Question.create('')

  end

end
