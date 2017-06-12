require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'pry'
require 'bcrypt'
require 'yaml'

configure do
  set :erb, :escape_html => true
end

get "/" do
  erb :index
end

get '/add' do
  erb :add
end

post "/add_contact" do
  redirect "/"
end
