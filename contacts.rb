require 'sinatra'
require "sinatra/reloader" if development?
require 'tilt/erubis'
require 'bcrypt'
require 'yaml'
require "sinatra/content_for"
require 'pry'

configure do
  enable :sessions
  set :erb, :escape_html => true
  set :session_secret, 'secret'
end

before do
  session[:contacts] ||= []
  @contacts = session[:contacts]
end

def parse_contact
  full_name = params[:first_name] + " " + params[:last_name]
  email, address, phone = params[:email], params[:address], params[:phone]

  new_contact = { :name => full_name, :email => email, :phone => phone, :address => address }
end

get "/" do
  erb :index
end

get '/add' do
  erb :add
end

get '/:contact/edit' do
  @contact = @contacts.select { |contact| contact[:name] == params[:contact] }.first

  @first_name, @last_name = @contact[:name].split
  @email = @contact[:email]
  @phone = @contact[:phone]
  @address = @contact[:address]

  erb :edit
end

post '/:contact/delete' do
  @contact = @contacts.select { |contact| contact[:name] == params[:contact] }.first
  @contacts.delete(@contact)
  
  session[:message] = "Contact has been deleted."
  redirect "/"
end

post "/add_contact" do
  new_contact = parse_contact
  session[:contacts] << new_contact

  session[:message] = "Contact has been added."
  redirect "/"
end

get "/add_contact" do
  new_contact = parse_contact
  session[:contacts] << new_contact

  session[:message] = "Contact has been added."
  redirect "/"
end

post "/:contact/edit_contact" do
  @contact = @contacts.select { |contact| contact[:name] == params[:contact] }.first
  @contacts.delete(@contact)

  edited_contact = parse_contact
  session[:contacts] << edited_contact
  session[:message] = "Contact has been updated."
  redirect "/"
end
