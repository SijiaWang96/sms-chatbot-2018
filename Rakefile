require "sinatra"
require "sinatra/reloader" if development?
require 'twilio-ruby'
require 'giphy'

# Load environment variables using Dotenv. If a .env file exists, it will
# set environment variables from that file (useful for dev environments)
configure :development do
  require 'dotenv'
  Dotenv.load
end

desc 'outputs hello world to the terminal'
task :hello_world do
  puts "Hello World from Rake!"
end

desc 'sends a test SMS to your twilio number'
task :send_sms do

  client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]
  message = "Hi, I am Guagua!"

 # this will send a message from any end point
   client.api.account.messages.create(
   from: ENV["TWILIO_FROM"],
   to: ENV["MY_NUMBER"]
   body: message
   )

end
