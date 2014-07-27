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
	puts "-----------------------------------------2"
	content_type :json
	{status: 201}.to_json
end