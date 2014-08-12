require 'sinatra'
require 'json'
require_relative 'models/chunk'

UPLOADER_MASK = ENV['UPLOADER_MASK'] || raise('UPLOADER_MASK not set')

before do
  raise 'id not set' if params[:id].to_i.zero?
  raise 'secret not correct' if params[:secret] != Digest::MD5.hexdigest("#{params[:id]}-#{UPLOADER_MASK}")

  @upload_dir = "#{settings.root}/uploads/#{params[:id].to_i}"
  FileUtils.mkdir(@upload_dir) unless File.directory?(@upload_dir)
end

# displays frontend
get '/' do
  erb :index
end

# receives file chunks
post '/upload' do
  files = []

  params[:files].each do |file|
    chunk = Chunk.new(@upload_dir, file[:filename])
    files << chunk.upload(file[:tempfile].path, request.env['HTTP_CONTENT_RANGE'])
  end

  if files.any?
    status 201
    {files: files}.to_json
  else
    raise 'should not happen'
  end
end

# returns the file info how much of the file has been uploaded so far
get '/upload' do
  if params[:file]
    chunk = Chunk.new(@upload_dir, params[:file])
    {file: {name: chunk.file_name, size: chunk.file_size}}.to_json
  else
    raise 'should not happen'
  end
end

# returns a list of name and size of all partially uploaded files
get '/list' do
  files = Dir.glob("#{@upload_dir}/*.part").map {|file| {name: File.basename(file, '.part'), size: File.size(file)}}
  {files: files}.to_json
end
