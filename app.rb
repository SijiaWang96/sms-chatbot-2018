require 'sinatra'
require "sinatra/reloader" if development?
require 'sinatra/activerecord'
require 'twilio-ruby'
require "unsplash"
require 'giphy'
require 'rake'
require 'httparty'

enable :sessions

configure :development do
  require 'dotenv'
  Dotenv.load
end

def what_do_you_like
  array_of_lines = IO.readlines("what_do_you_like.txt")
  message = "Em.... "+ array_of_lines.sample.to_s
  return message
end

def recommend_city
array_of_lines = IO.readlines("recommend_city.txt")
sampled = array_of_lines.sample.to_s
items = []
items = sampled.split("=")
city = items[0]
recommendation = items[1]
message = "I will recommend " + items[1].to_s
media = search_unsplash_for (items[0].to_s)
return message, media
end
# def search_answer_for body
# array_of_lines = IO.readlines("search_for_anwser.txt")
# array_of_lines.each d o |line|
#   items=line.split (";")
#     items.each do |item|
#       if body.include? item
#       message = "That's great, Thanks your advice!"
#       #media = search_giphy_for item
#       else
#       message = "I'd better like" + items.sample.to_s
#       end
#       return message
#     end
#   end
# end

def search_unsplash_for query

  Unsplash.configure do |config|
    config.application_access_key = ENV['UNSPLASH_ACCESS']
    config.application_secret = ENV['UNSPLASH_SECRET']
    config.utm_source = "ExampleAppForClass"
  end

  search_results = Unsplash::Photo.search( query, 1, 1)
  puts search_results.to_json

  media = ""
  puts search_results.size
  search_results.each do |result|
    #puts result.to_json
  puts "Result"
  #message = "GuaGua sent you photo from "+ query.to_s + "." + result["description"].to_s + result["created_at"].to_s
  media = result["urls"]["thumb"].to_s
  end
  return media

end

get "/test/unsplash/:term" do

  Unsplash.configure do |config|
    config.application_access_key = ENV['UNSPLASH_ACCESS']
    config.application_secret = ENV['UNSPLASH_SECRET']
    config.utm_source = "ExampleAppForClass"
  end

  search_term = "beach"
  search_term = params[:term] # use the provided search term
  # search for whatever search term, give 1 page of results, with 3 results per page
  search_results = Unsplash::Photo.search( search_term, 1, 1)
  puts search_results.to_json
  images = ""
  search_results.each do |result|
    #puts result.to_json
  puts "Result"
  image_thumb = result["urls"]["thumb"]
    puts result["urls"]["thumb"].to_json
    image_description = result["description"].to_s
    images += "<img src='#{ image_thumb.to_s }' /><br/>"
    images += "<hr/>"
  end
  return images

end

def detect_intent_texts project_id:, session_id:, texts:, language_code:
  # [START dialogflow_detect_intent_text]
  # project_id = "Your Google Cloud project ID"
  # session_id = "mysession"
  # texts = "hello", "book a meeting room"]
  # language_code = "en-US"

  session_client = Google::Cloud::Dialogflow::Sessions.new
  session = session_client.class.session_path ENV["GOOGLE_CLOUD_PROJECT_ID"], session_id
  puts "Session path: #{session}"

  texts.each do |text|
    query_input = { text: { text: text, language_code: language_code } }
    response = session_client.detect_intent session, query_input
    query_result = response.query_result

    puts "Query text:        #{query_result.query_text}"
    puts "Intent detected:   #{query_result.intent.display_name}"
    puts "Intent confidence: #{query_result.intent_detection_confidence}"
    puts "Fulfillment text:  #{query_result.fulfillment_text}\n"
  end
  # [END dialogflow_detect_intent_text]
end


daytimegreeting = ["<h1>Hi! ", "<h1>Hey! ","<h1>what's up!"]
eveninggreeting = ["<h1>Good evening! ", "<h1>Evening! "]


def city_message
  cities = ["Beijing","Shanghai","Chicago","New York"]
  city = cities.sample
  message = "Guagua sent photos from " + city.to_s
  media = search_giphy_for (city.to_s)
  return message, media
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
    gif = results.sample.original_image.url
    return gif.to_s

  else
    return nil
  end

end

def include_words sentence, words
  words.each do |word|
		if sentence.include? word
			return true
		end
	end
	return false
end

def determine_response body
  body = body.to_s.downcase.strip
  message = " "
  media = nil
  session[:lastquestion] ||= 0
  #project_id = ENV["GOOGLE_CLOUD_PROJECT_ID"]
  #intent = detect_intent_texts project_id: project_id,
                      #  session_id: SecureRandom.uuid,
                      #  texts: [body],
                      #  language_code:"en-US"

  hi_words = ["hi", "hello", "hey", "what's up"]
  who_words =["who"]
  what_words =["what", "help", "feature", "function", "guide"]
  when_words = ["when", "created", "born", "made","brith"]
  # if  Time.now.hour.to_i>=12 && Time.now.hour.to_i<14
  # message = "[Auto-replying...] Guagua is eating breakfast!"
  # media = search_giphy_for("breakfast")
  # #elsif Time.now.hour.to_i>=17 && Time.now.hour.to_i<19
  # #message = "Guagua is eating lunch!"
  # #media = search_giphy_for("lunch")
  # elsif Time.now.hour.to_i>=22 && Time.now.hour.to_i<24
  # message = "[Auto-replying...]Guagua is eating dinner!"
  # media = search_giphy_for("dinner")
  # elsif Time.now.hour.to_i>=4 && Time.now.hour.to_i<12
  # message = "[Auto-replying...]Guagua is sleeping!"
  # media = search_giphy_for("sleeping")
  # else

      if body == "hi" or include_words body,hi_words
      message = hi_words.sample + ", I am Guagua!"
      elsif body.include? "who"
      message = "I am a duck, my name is Guagua. I was created by Sijia which is my mom. Do not say bad at me, or I will call my mom!"
      elsif body == "what" or include_words body, what_words
      message ="I am a duck like traveling！I will send you photos from all over the world！And I can recommend you a traveling city, if you type something like “recomme me a city”. Also, I will ask you questions when I am really hard to choose things!"
      elsif body =="where"
      message = "I am traveling all over the world!"
      elsif body =="when" or include_words body, when_words
      message ="I was born in 2018."
      elsif body.include?"why"
      message = "I was made for a class project programing for online prototypes class in CMU."
      elsif body.include? "haha" or body.include?"lol" or body.include?"hhh"
      message = "Funny,righ?"
      elsif body.include? "nice" or body.include?"intereting" or body.include?"amazing"
      message = "I think so!"
      elsif body.include? "love you" or body.include? "like you" or body.include? "miss you"
      message = "Are you boring now?"
      elsif body.include? "boring"
      message = "Think about your assignments! Go back to work!"
      elsif body.include? "yes"
      message = ":)"

      elsif body.include? "recommend" or  body.include?"recommendation"
      message, media = recommend_city
      elsif session[:lastquestion] != 0

        array_of_lines = IO.readlines("responses.txt")
        array_of_lines.each do |line|
          # sampled = "What do you think I should eat for dinner? Bread or Noodles?;Bread;Noodle;Thanks for the advice!"
          # #sample = sampled.to_s.downcase.strip
           items = []
           items = line.split( ";")
           question = items[0] # question
           response1 = items[1]
           response2 = items[2]
           reply = items[3]

          if (session[:lastquestion] == question) && (items[2] != nil)
            # response here...
            if (body.include? response1) or (body.include? response2)
                message = reply
                media  = search_giphy_for ("happy")
                #session[:lastquestion] = 0
            else
               message = "I think I will choose " + items[1]
               media = search_giphy_for ("confused")
               #session[:lastquestion] = 0
            end

          # elsif session[:lastquestion] != question
          #   session[:lastquestion] = 0
          #
          # else
          #   message = session[:lastquestion]
          end

      end
      session[:lastquestion] = 0
      #guaguas = []
      #guaguas = line.split( "is")
      #media = search_giphy_for (item[1])
      # message = session[:lastquestion]

      #message = "That's great, Thanks your advice!"
      #elsif body.include? "t-shirt" || "jacket"
      #message = "Do you want to freeze me?"
      else
        #array_of_lines = IO.readlines("what_do_you_like.txt")
        #question = array_of_lines.sample.to_s
        #message = "Em.... "+ question
        sigh_words=["... ", "Em.... ", "Hm... "]
        array_of_lines = IO.readlines("responses.txt")
        sampled = array_of_lines.sample.to_s
        items = []
        items = sampled.split( ";")
        question = items[0] # question
        response1 = items[1]
        response2 = items[2]
        reply = items[3]
        session[:lastquestion] = items[0]
        # session[:lastquestion_responses1] = response1
        # session[:lastquestion_responses2] = response2
        # session[:lastquestion_reply] = reply
        media = search_giphy_for ("confused")
        message = sigh_words.sample.to_s + session[:lastquestion].to_s
      end
    #end
  #end
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
 #rake send_sms
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
  body = params[:Body]||""
  sender = params[:From]||""
  greeting = []
#  ====== sample
    if session["counter"] == 1
      message = "[Auto-replying...] Hi~ I am Guagua~ Your friend! If you want to know about me, you can type something like “who are you”, “what do you do?”"
      media = nil
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
