require 'sinatra'
require 'sinatra/config_file'
require 'sinatra/reloader' if development?
require 'json'
require_relative 'models/chunk'

config_file 'config/config.yml'

before do
  if params[:id].to_i.zero?
    halt(403, 'ERROR: id not set')
  end
  if params[:secret] != Digest::MD5.hexdigest("#{params[:id]}-#{settings.uploader_mask}")
    halt(403, 'ERROR: secret not correct')
  end

  @upload_dir = File.expand_path("#{settings.upload_dir}/#{params[:id].to_i}")
  Dir.mkdir(@upload_dir) unless File.directory?(@upload_dir)
end

helpers do
  def validate_file_extension(file)
    ext = File.extname(file)[1..-1]
    halt(415, "ext <#{ext}> not allowed") unless settings.accepted_file_types.include?(ext)
  end
end

# displays frontend
get '/' do
  erb :index
end

# receives file chunks
post '/upload' do
  files = []

  params[:files].each do |file|
    validate_file_extension(file[:filename])
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
    if chunk.file_complete?
      {file: {
          name: chunk.file_name,
          error: "ERROR: The file '#{chunk.file_name}' already exists at the server."}
      }.to_json
    else
      {file: {name: chunk.file_name, size: chunk.file_size}}.to_json
    end
  else
    raise 'should not happen'
  end
end

# returns a list of name and size of all partially uploaded files
get '/list' do
  files = []
  Dir.glob("#{@upload_dir}/*.*").each do |file|
    hash = {
        name: File.basename(file, '.part'),
        size: File.size(file),
    }
    if File.extname(file) == '.part'
      hash[:delete_url] = "/delete?id=#{params[:id]}&secret=#{params[:secret]}&file=#{CGI.escape(File.basename(file))}"
    else
      hash[:complete] = true
    end
    files << hash
  end
  {files: files}.to_json
end

delete '/delete' do
  file = "#{@upload_dir}/#{File.basename(params[:file])}"
  if File.file?(file) && File.delete(file)
    {
        files: [
            {params[:file] => true}
        ]
    }.to_json
  else
    raise 'should not happen'
  end
end
