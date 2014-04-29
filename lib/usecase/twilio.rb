require 'twilio-ruby'
require 'dotenv'
Dotenv.load
class SendText < UseCase
  def run(inputs)
    @twilio_number = '5122706595'
    @client = Twilio::REST::Client.new ENV['account_sid'], ENV['auth_token']
    @client.account.sms.messages.create(
    :from => @twilio_number,
    :to => inputs[:phone_number],
    :body => inputs[:body])
  end
end
