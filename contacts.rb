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
  @root = File.expand_path("..", __FILE__)

  session[:contacts] ||= []
  @contacts = session[:contacts]
end

def parse_contact
  full_name = params[:first_name] + " " + params[:last_name]
  email, address, phone = params[:email], params[:address], params[:phone]

  new_contact = { :name => full_name, :email => email, :phone => phone, :address => address }
end

def load_user_credentials
  credentials_path = File.join(@root, "users.yaml")
  YAML.load_file(credentials_path)
end

def valid_credentials?(username, password)
  credentials = load_user_credentials

  if credentials.key?(username)
    bcrypt_password = BCrypt::Password.new(credentials[username])
    bcrypt_password == password
  else
    false
  end
end

def add_user_to_database(username, password)
  credentials = load_user_credentials
  credentials[username] = password.to_s
  File.open("./users.yaml", "wb") { |f| f.write(credentials.to_yaml) }
end

get "/" do
  credentials = load_user_credentials

  if credentials.key?(session[:username])
    redirect "/index"
  else
    erb :signin
  end
end

get "/index" do
  erb :index
end

post "/signin" do
  username = params[:username]
  password = params[:password]

  if valid_credentials?(username, password)
    session[:message] = "Welcome"
    session[:username] = username
    redirect "/index"
  else
    session[:message] = "Invalid credentials."
    erb :signin
  end
end

post "/signup" do
  username = params[:username]
  password = params[:password]

  bcrypt_password = BCrypt::Password.create(password)
  add_user_to_database(username, bcrypt_password)

  session[:message] = "You have been registered. Please sign in."
  redirect "/"
end

post "/signout" do
  session.delete(:username)
  session[:message] = "You have been signed out."
  redirect "/"
end

get '/signup' do
  erb :signup
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
  redirect "/index"
end

post "/add_contact" do
  new_contact = parse_contact
  session[:contacts] << new_contact

  session[:message] = "Contact has been added."
  redirect "/index"
end

get "/add_contact" do
  new_contact = parse_contact
  session[:contacts] << new_contact

  session[:message] = "Contact has been added."
  redirect "/index"
end

post "/:contact/edit_contact" do
  @contact = @contacts.select { |contact| contact[:name] == params[:contact] }.first
  @contacts.delete(@contact)

  edited_contact = parse_contact
  session[:contacts] << edited_contact
  session[:message] = "Contact has been updated."
  redirect "/index"
end
