require 'sinatra'
require 'json'
require './app/chunkload.rb'

set :root, File.dirname(__FILE__)

enable :sessions
set :session_secret, 'its_a_secret_phrase_for_large_file_upload_system_security'

# display a rudimentary chunked uploader frontend
get '/' do
	erb :index
end


#recieves file chunks
post '/upload' do
	

	upload_dir = "uploads"
	results = []

	params[:files].each do |file_chunk|
		results << Chunkload.upload_chunk(file_chunk, request.env['HTTP_CONTENT_RANGE'], upload_dir)
	end

	if results.any?
		content_type :json
		{status: 201, files: results }.to_json
	else
		[500, {},{}]
	end
end


#returns the file info when javascript uploader
#wants to find out how much of the file has been uploaded
get '/upload' do

	result = Chunkload.check('uploads', params["file"])

	if result
		content_type :json
		{status: 200, file: result}.to_json
	else
		[500, {}, {}]
	end

end