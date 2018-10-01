require 'sinatra'
require "sinatra/reloader" if development?
require 'twilio-ruby'
require 'giphy'

configure :development do
  require 'dotenv'
  Dotenv.load
end

enable :sessions
daytimegreeting = ["<h1>Hi! ", "<h1>Hey! ","<h1>what's up!"]
eveninggreeting = ["<h1>Good evening! ", "<h1>Evening! "]
cities = ["Beijing","Shanghai","Chicago", "New York"]

def get_city
  return cities.sample
end

def city_message
  city = get_city
  media = search_giphy_for(get_city)
  return "Guagua sent photos from" + city, media
end

def first_greeting time
"</h1><p>My app does xyz. You have visited at " + time.strftime("%A %B %d, %Y %H:%M").to_s + ' .'
end

def normal_greeting time
"<h1>Welcome back! " + "</h1><p> My app does xyz. You have visited " + session["visits"].to_s + " times as of " + time.strftime("%A %B %d, %Y %H:%M").to_s + ' .'
end
# detemine the different types of greeting
def search_giphy_for query

  Giphy::Configuration.configure do |config|
    config.api_key = ENV["GIPHY_API_KEY"]
  end

  results = Giphy.search(query, {limit: 20})

  unless results.empty?
    #puts results.to_yaml
    gif = results.first.original_image.url
    return gif

  else
    return nil
  end

end

def determine_response body
      body = body.to_s.downcase.strip
      message = " "
      media = nil

      if body == "hi"
      message = "Hi, I am Guagua！Photos sent form New York!"
      media = "https://media.giphy.com/media/14uPT7tV9i73hO8RSV/giphy.gif"
      elsif body == "who"
      message = "This is a MeBot. I was created by Sijia which is my mom. Do not say bad at me, or I will call my mom!"
      elsif body == "what"
      message ="Respond with an explanation that the bot can be used to ask basic things about you"
      elsif body =="where"
      message = "I amin Pittsburgh"
      elsif body =="when"
      message ="I was made in Fall 2018."
      elsif body == "why"
      message = "I was made for a class project in CMU programing for online prototypes."
      #elsif params[:body] == "fact"
      #  array_of_lines = IO.readlines("fact.txt")
      #  message = array_of_lines.sample(1).to_s + " "+ "<h1><p>lol"
      else
      media = search_giphy_for body
      end

      return message, media

end
# conversation design

get '/' do
    redirect "/about"
end

get '/about' do

    session["visits"] ||= 0
    session["visits"] = session["visits"] + 1
    time = Time.now
    if session["visits"] == 1
      if time.dst?  == TRUE
        daytimegreeting.sample + " " +  first_greeting(time)
      else
        eveninggreeting.sample + " " +  first_greeting(time)
      end
    else
      if time.dst? == TRUE
        daytimegreeting.sample + " " +  normal_greeting(time)
      else
        eveninggreeting.sample + " " +  normal_greeting(time)
      end
    end

end
# greeting

get '/signup' do
    erb :signup
end
# signup form
post "/signup" do
#  secret = "13269559220"
#  if params[:code].nil?
#  return "Please input your code!"
#  elsif  params[:code] == secret
#  return "You've got the code"
#  else
#  return 403
#  end
# code to check parameters
 #if params[:first_name].nil? || params[:number].nil?
 #return  "You forget input firstname or number! "
 #elsif params[:first_name].nil? && params[:number].nil?
 #return  "Please input firstname & number ! "
 #else
   client = Twilio::REST::Client.new ENV["TWILIO_ACCOUNT_SID"], ENV["TWILIO_AUTH_TOKEN"]
   message = "Hi," + params[:first_name] + ", welcome to MeBot! I can respond to who, what, where, when and why. If you're stuck, type help."

  # this will send a message from any end point
    client.api.account.messages.create(
    from: ENV["TWILIO_FROM"],
    to: params[:number],
    body: message
    )
	# response if eveything is OK
	"You're signed up. You'll receive a text message in a few minutes from the bot. "
end

get "/sms/incoming" do
   session["counter"] ||= 1
  body = params[:Body]
  sender = params[:From]
#  ====== sample
    if session["counter"] == 1
      message = "Thanks for your first message.From #{sender} saying [#{body}]"
      media = "https://media.giphy.com/media/13ZHjidRzoi7n2/giphy.gif"
    else
      message, media = determine_response body
    end

#  message = "testtttt!"



  # Build a twilio response object
  twiml = Twilio::TwiML::MessagingResponse.new do |r|
    r.message do |m|

      # add the text of the response
      m.body( message )

      # add media if it is defined
      unless media.nil?
        m.media( media )
      end
    end
  end

  # increment the session counter
   session["counter"] += 1

  # send a response to twilio
  content_type 'text/xml'
  twiml.to_s

end
# firstconversation

get '/test/conversation/:body/:from' do

    if params[:body].nil? || params[:from].nil?
	  return  "You forget input body or form! "
    elsif params[:body].nil? && params[:body].nil?
    return  "Please input body & from ! "
    else
    determine_response params[:body]
    end

end
