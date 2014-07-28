require 'sinatra'
require 'json'

set :root, File.dirname(__FILE__)

get '/' do
	erb :index
end

post '/upload' do
	puts "------------debug params:----------------"
	puts params.inspect
	puts "------------content-range:---------------"
	puts request.env['HTTP_CONTENT_RANGE']
	puts "-----------------------------------------"

	temp_file_location = params["files"][0][:tempfile].path

	result = %x(cat #{temp_file_location} >> uploads/upload_test)

	puts "------------filesystem operation result:--"
	puts result
	puts "------------------------------------------"

	content_type :json
	{status: 201}.to_json
end