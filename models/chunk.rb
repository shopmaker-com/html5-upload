require 'shellwords'

class Chunk
  def initialize(upload_dir, file_name, temp_file=nil)
    @file_name = file_name #file[:filename]
    @upload_dir = upload_dir #Sinatra::Application.settings.upload_dir
    @file_path = "#{@upload_dir}/#{@file_name}"
    @partial_file_path = "#{@file_path}.part"
  end

	def upload(temp_file, content_range)
		# extract data about incoming file chunk form the http Content_range header
    content_range = content_range.match(/[0-9]+-([0-9]+)\/([0-9]+)/)
    uploaded_bytes = content_range[1].to_i
    expected_bytes = content_range[2].to_i

    #file on disk doesn't have the incoming chunk, append the chunk
    if file_size < uploaded_bytes
      #implicit return true if success, false on fail
      Kernel.system("cat #{temp_file} >> #{Shellwords.escape(@partial_file_path)}")
    end

		#handle last chunk rename, i.e. remove ".part" from the end of filename
		if expected_bytes - uploaded_bytes == 1
			# it's the last chunk, because bytes_uploaded is counted from zero
			# so when subtracted from the file length difference is one
			FileUtils.mv Shellwords.escape(@partial_file_path), Shellwords.escape(@file_path)
		end 

		{name: @file_name, size: expected_bytes, uploadedBytes: file_size}
  end

  def file_size
    File.exists?(@partial_file_path) ? File.size(@partial_file_path) : 0
  end

	def check
		{name: @file_name, size: file_size}
	end
end
