require 'twilio-ruby'
require 'giphy'
require 'rake'
# Load environment variables using Dotenv. If a .env file exists, it will
# set environment variables from that file (useful for dev environments)
  require 'dotenv'
  Dotenv.load

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



def city_message

    cities = ["Beijing","Shanghai","Chicago","New York"]
    city = cities.sample
    message = "Guagua sent photos from" + city.to_s
    media = search_giphy_for (city.to_s)
    return message, media

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
   to: ENV["MY_NUMBER"],
   body: message
   )

end

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
