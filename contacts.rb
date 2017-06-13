require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'pry'
require 'bcrypt'
require 'yaml'

configure do
  enable :sessions
  set :session_secret, 'secret'
end

before do
  session[:contacts] ||= []
  @contacts = session[:contacts]
end

def parse_contact
  full_name = params[:first_name] + " " + params[:last_name]
  email, address, phone = params[:email], params[:address], params[:phone]

  new_contact = { full_name => { "Email" => email, "Phone" => phone, "Address" => address } }
end

get "/" do
  erb :index
end

get '/add' do
  erb :add
end

get '/:contact/edit' do
  contact_to_edit = params[:contact]
  @contact = @contacts.select { |c| c.keys.first == contact_to_edit }.first

  @first_name, @last_name = @contact.keys.first.split
  @email = @contact[contact_to_edit]["Email"]
  @phone = @contact[contact_to_edit]["Phone"]
  @address = @contact[contact_to_edit]["Address"]

  erb :edit
end

post '/:contact/delete' do
  @contacts.reject! { |contact| contact.include?(params[:contact]) }
  redirect "/"
end

post "/add_contact" do
  new_contact = parse_contact
  session[:contacts] << new_contact
  redirect "/"
end

post "/edit_contact" do
  new_contact = parse_contact
  session[:contacts] << new_contact
  redirect "/"
end
