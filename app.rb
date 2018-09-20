require 'sinatra'
require "sinatra/reloader" if development?
require 'twilio-ruby'

configure :development do
  require 'dotenv'
  Dotenv.load
end

enable :sessions
daytimegreeting = ["<h1>Hi! ", "<h1>Hey! ","<h1>what's up!"]
eveninggreeting = ["<h1>Good evening! ", "<h1>Evening! "]
whatelse = ["what", "feature", "function", "action"]
def first_greeting time
"</h1><p>My app does xyz. You have visited at " + time.strftime("%A %B %d, %Y %H:%M").to_s + ' .'
end

def normal_greeting time
"<h1>Welcome back! " + "</h1><p> My app does xyz. You have visited " + session["visits"].to_s + " times as of " + time.strftime("%A %B %d, %Y %H:%M").to_s + ' .'
end
# detemine the different types of greeting

def determine_response body
body = body.to_s.downcase.strip

      if params[:body] == "hi"
        "Add a general greeting for your bot. Explain its functionality"
      elsif params[:body] == "who"
        "This is a MeBot. I was created by Sijia which is my mom. Do not say bad at me, or I will call my mom!"
      elsif params[:body] == "what"
        "Respond with an explanation that the bot can be used to ask basic things about you"
      elsif params[:body] == "where"
        "I amin Pittsburgh"
      elsif params[:body] == "when"
        "I was made in Fall 2018."
      elsif params[:body] == "why"
        "I was made for a class project in CMU programing for online prototypes."
      elsif params[:body] == "fact"
        array_of_lines = IO.readlines("fact.txt")
        array_of_lines.sample(1).to_s + " "+ "<h1><p>lol"

      else
        "I cannot understand. You can ask me who I am."
      end

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
      if time.dst? == TRUE
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
   message = "Hi" + params[:first_name] + ", welcome to BotName! I can respond to who, what, where, when and why. If you're stuck, type help."

  # this will send a message from any end point
    client.api.account.messages.create(
    from: ENV["TWILIO_FROM"],
    to: params[:number],
    body: message
    )
	# response if eveything is OK
	"You're signed up. You'll receive a text message in a few minutes from the bot. "
#end

# signup sms

end

get "/sms/incoming" do
  # session["counter"] ||= 1
  #body = params[:Body]
  # sender = params[:From]

   # if session["counter"] == 1
   #   message = "Thanks for your first message."
   #   #media = "https://media.giphy.com/media/13ZHjidRzoi7n2/giphy.gif"
   # else
   #   message = "Thanks for message."
   #   #media = nil
   # end


  message = "testtttt!"

  # Build a twilio response object
  twiml = Twilio::TwiML::MessagingResponse.new do |r|
    r.message do |m|

      # add the text of the response
      m.body( message )

      # add media if it is defined
      #unless media.nil?
        #m.media( media )
      #end
    end
  end

  # increment the session counter
  # session["counter"] += 1

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
