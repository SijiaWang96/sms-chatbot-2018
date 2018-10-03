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
