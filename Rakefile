require 'sinatra'
require 'twilio-ruby'
require 'giphy'
require 'rake'
require "unsplash"
# Load environment variables using Dotenv. If a .env file exists, it will
# set environment variables from that file (useful for dev environments)

configure :development do
  require 'dotenv'
  Dotenv.load
end

def search_giphy_for query

  Giphy::Configuration.configure do |config|
    config.api_key = ENV["GIPHY_API_KEY"]
  end

  results = Giphy.search(query, {limit: 20})

  unless results.empty?
    #puts results.to_yaml
    gif = results.sample.original_image.url
    return gif.to_s
  else
    return nil
  end

end

def search_unsplash_for response

  Unsplash.configure do |config|
    config.application_access_key = ENV['UNSPLASH_ACCESS']
    config.application_secret = ENV['UNSPLASH_SECRET']
    config.utm_source = "ExampleAppForClass"
  end

  search_results = Unsplash::Photo.search( response, 1, 1)
  puts search_results.to_json
  media = ""
  message = ""
  puts search_results.size
  search_results.each do |result|
    #puts result.to_json
  puts "Result"
  message = "GuaGua sent you photo from "+ query.to_s + ". This is " + result["description"].to_s + "."
  media_thumb = result["urls"]["thumb"]
    puts result["urls"]["thumb"].to_json
    media += "<img src='#{ media_thumb.to_s }' /><br/>"
  end
  return message, media

end


def city_message 
    cities = ["Beijing","Shanghai","Chicago","New York"]
    city = cities.sample
    message, media = search_unsplash_for (city.to_s)
    return message, media
end

#desc 'outputs hello world to the terminal'
#task :hello_world do
#  puts "Hello World from Rake!"
#end

#desc 'sends a test SMS to your twilio number'
#task :send_sms do

#  client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]
#  message = "Hi, I am Guagua!"

 # this will send a message from any end point
#   client.api.account.messages.create(
#   from: ENV["TWILIO_FROM"],
#   to: ENV["MY_NUMBER"],
#   body: message
#   )

#end

desc 'sends a test MMS to your twilio number'
task :send_photo do

  client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]
  message, media = city_message


   client.api.account.messages.create(
   from: ENV["TWILIO_FROM"],
   to: ENV["MY_NUMBER"],
   body: message,
   media_url: media
   )

end

desc 'sends a test MMS to TROY number'
task :send_photo_troy do

  client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]
  message, media = city_message


  client.api.account.messages.create(
   from: ENV["TWILIO_FROM"],
   to: ENV["TROY_NUMBER"],
   body: message,
   media_url: media
   )

end
