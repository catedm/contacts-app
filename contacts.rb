require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'pry'
require 'bcrypt'
require 'yaml'

get "/" do

  erb :index
end
