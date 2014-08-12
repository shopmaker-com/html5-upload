require 'shellwords'

class Chunk
  attr_reader :file_name

  def initialize(upload_dir, file_name)
    @upload_dir = upload_dir
    @file_name = file_name
    @file_path = "#{@upload_dir}/#{@file_name}"
    @partial_file_path = "#{@upload_dir}/#{@file_name}.part"
  end

  def upload(temp_file, content_range)
    # extract data about incoming file chunk from the http_content_range header
    content_range = content_range.match(/[0-9]+-([0-9]+)\/([0-9]+)/)
    uploaded_bytes = content_range[1].to_i
    expected_bytes = content_range[2].to_i
    raise "http_content_rage is not set" if uploaded_bytes.zero? || expected_bytes.zero?

    #file on disk doesn't have the incoming chunk, append the chunk
    if file_size < uploaded_bytes
      Kernel.system("cat #{Shellwords.escape(temp_file)} >> #{Shellwords.escape(@partial_file_path)}")
    end

    #handle last chunk rename (remove ".part" from the end of filename)
    # it's the last chunk, because uploaded_bytes is counted from zero
    # so when subtracted from the file length the difference is one
    FileUtils.mv @partial_file_path, @file_path if expected_bytes - uploaded_bytes == 1

    {name: @file_name, size: expected_bytes, uploadedBytes: file_size}
  end

  def file_size
    File.exists?(@partial_file_path) ? File.size(@partial_file_path) : 0
  end
end
