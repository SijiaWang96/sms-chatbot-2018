require 'sinatra'
require "sinatra/reloader" if development?

cities = ["Beijing","Shanghai","Chicago"]
sample = array.sample

def get_city
  return cities.random
end

def city_message
  city = get_city
  media = GIP
  return "Hi I've been to " + city, media
end


get "/" do
  "Hi, I have been to " + message(en) + ". This my image. " + media(ha)
end

get "/test_cem"
message, media = city_message
end
