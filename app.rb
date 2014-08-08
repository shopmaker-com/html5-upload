require 'sinatra'
require 'json'
require_relative 'models/chunk'

enable :sessions
set :session_secret, 'its_a_secret_phrase_for_large_file_upload_system_security'
set :upload_dir, "#{settings.root}/uploads"

# displays frontend
get '/' do
  erb :index
end

# receives file chunks
post '/upload' do
  results = []

  params[:files].each do |file|
    chunk = Chunk.new(Sinatra::Application.settings.upload_dir, file[:filename])
    results << chunk.upload(file[:tempfile].path, request.env['HTTP_CONTENT_RANGE'])
  end

  if results.any?
    content_type :json
    {status: 201, files: results}.to_json
  else
    status 500
  end
end

# returns the file info when javascript uploader wants
# to find out how much of the file has been uploaded so far
get '/upload' do
  content_type :json

  chunk = Chunk.new(Sinatra::Application.settings.upload_dir, params[:file])
  {status: 200, file: chunk.check}.to_json
end
