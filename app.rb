require 'sinatra'
require 'sinatra/contrib'
require 'twilio-ruby'
require 'dotenv'
require 'rotp'
Dotenv.load

enable :sessions
require_relative 'lib/inquizitive.rb'




