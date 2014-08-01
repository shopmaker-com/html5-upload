require 'sinatra'
require 'json'
require_relative 'models/chunkload'

enable :sessions
set :session_secret, 'its_a_secret_phrase_for_large_file_upload_system_security'
set :upload_dir, "#{settings.root}/uploads"

# display frontend
get '/' do
	erb :index
end

# receives file chunks
post '/upload' do
	results = []

	params[:files].each do |file_chunk|
		results << Chunkload.upload_chunk(file_chunk, request.env['HTTP_CONTENT_RANGE'], settings.upload_dir)
	end

	if results.any?
		content_type :json
		{status: 201, files: results }.to_json
	else
		status 500 # server error
	end
end

# returns the file info when javascript uploader wants
# to find out how much of the file has been uploaded so far
get '/upload' do
	result = Chunkload.check(settings.upload_dir, params[:file])

	if result
		content_type :json
		{status: 200, file: result}.to_json
	else
		status 500 # server error
	end
end
