#Handles chunked uploads by ensuring that chunks get to their intended destination

# Shellwords.escape() deals with spaces and other special symbols in the filename
require 'shellwords'

class Chunkload
	def self.target_partialfile_name(upload_dir, filename)
		"#{upload_dir}/#{filename}.part"
	end

	def self.append_chunk(chunk_path = nil, upload_dir = nil, filename = nil)
		target_path = target_partialfile_name(upload_dir, filename)

		#implicit return true if success, false on fail
		Kernel.system("cat #{chunk_path} >> #{Shellwords.escape(target_path)}")
	end

	def self.upload_chunk(http_param_file, content_range, upload_dir)
		temp_file_location = http_param_file[:tempfile].path
		filename = http_param_file[:filename]


		# extract data about incoming file chunk form the http Content_range header
		extract_upload_progress = content_range.match(/([0-9]+)-([0-9]+)\/([0-9]+)/)

		uploaded_chunk_index = extract_upload_progress[2].to_i
		expected_bytes_total = extract_upload_progress[3].to_i

		#check for existence, we don't want to append the chunk if it's allready there
		target_path = target_partialfile_name(upload_dir, filename)


		if File.exists?(target_path) then
			current_filesize = File.size(target_path)
		else
			current_filesize = 0
		end

		if (current_filesize < uploaded_chunk_index) then
			#file on disk doesn't have the incoming chunk, append the chunk
			append_chunk(temp_file_location, upload_dir, filename)
		else
			#file on disk already has the incoming chunk, ignore
		end

		#handle last chunk rename, i.e. remove ".part" from the end of filename

		if (expected_bytes_total-uploaded_chunk_index) == 1 then
			# it's the last chunk, because bytes_uploaded is counted from zero
			# so when subtracted from the file length difference is one
			new_file_path = "#{upload_dir}/#{filename}"
			whole_argument = "#{target_path} #{new_file_path}"
			# puts "------------------rename command---------------------"
			# puts "mv #{Shellwords.escape(whole_argument)}"
			Kernel.system("mv #{Shellwords.escape(target_path)} #{Shellwords.escape(new_file_path)}")
		end 

		return {name: filename, size: expected_bytes_total, uploadedBytes: current_filesize}
	end

	def self.check(upload_dir, filename)

		target_path = target_partialfile_name(upload_dir, filename)

		if File.exists?(target_path) then
			current_filesize = File.size(target_path)
		else
			current_filesize = 0
		end

		return {size: current_filesize, name: filename}
	end
end