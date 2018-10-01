require 'sinatra'
require "sinatra/reloader" if development?

get "/" do
time = Time.now
if  Time.now.hour.to_i>7 && Time.now.hour.to_i<18
  " hi !"
else
  " good evening! "
end
end
