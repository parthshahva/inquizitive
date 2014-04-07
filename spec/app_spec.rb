require 'spec_helper'
require_relative '../app.rb'
  describe "get /" do
    it "should display the homepage" do
      get "/"
      last_response.should be_ok
    end
  end
  describe "sign-up" do
    it "should insert a user into the users table" do
      lambda do
        post "/sign-up", params = {
          :username => 'poppycock',
          :password  => 'titty',
          :phone_number  => '4693230314',
        }
      end.should {
        change(User, :count).by(1)
      }
    end
    it 'should throw an error if the desired username already exists ' do
      lambda do
        post "/sign-up", params = {
          :username => 'poppycock',
          :password  => 'titty',
          :phone_number  => '2040608010',
        }
        post "/sign-up", params = {
          :username => 'poppycock',
          :password  => 'titty',
          :phone_number  => '1234567890',
        }
      end.should {
        change(User, :count).by(1)

      }
    end
end
