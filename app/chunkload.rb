#Handles chunked uploads by ensuring that chunks get to their intended destination
require 'shellwords'

class Chunkload

	def self.move_chunk(chunk_path = nil, upload_dir = nil, filename = nil)
		#deal with spaces and other special symbols in filenames
		target_file_name = Shellwords.escape(target_partialfile_name(filename))
		target_path = "#{upload_dir}/#{target_file_name}"

		#implicit return true if success, false on fail
		Kernel.system("cat #{chunk_path} >> #{target_path}")
	end

	def self.upload_chunk(http_param_file, content_range, upload_dir)
		temp_file_location = http_param_file[:tempfile].path
		filename = http_param_file[:filename]

		#check for existence
		target_file_name = Shellwords.escape(target_partialfile_name(filename))
		target_path = "#{upload_dir}/#{target_file_name}"

		extract_upload_progress = content_range.match(/([0-9]+)-([0-9]+)\/([0-9]+)/)

		uploaded_chunk_index = extract_upload_progress[2].to_i
		expected_bytes_total = extract_upload_progress[3].to_i

		if File.exists?("#{upload_dir}/#{filename}.part") then
			current_filesize = File.size("#{upload_dir}/#{filename}.part")
		else
			current_filesize = 0
		end

		if (current_filesize < uploaded_chunk_index) then
			#file on disk doesn't have the incoming chunk, move the chunk
			result = move_chunk(temp_file_location, upload_dir, filename)
		else
			#file on disk already has the incoming chunk, ignore
		end

		#handle last chunk target rename, i.e. remove ".part" from the end

		if (expected_bytes_total-uploaded_chunk_index) == 1 then
			# it's the last chunk, because bytes_uploaded is counted from zero
			new_file_name = Shellwords.escape(filename)
			new_file_path = "#{upload_dir}/#{new_file_name}"
			Kernel.system("mv #{target_path} #{new_file_path}")
		end 

		return {name: filename, size: expected_bytes_total, uploadedBytes: current_filesize}
	end

	def self.target_partialfile_name(filename = nil, uid = nil)
		"#{filename}.part"
	end

	def self.check(upload_dir, filename)

		puts "checking if #{upload_dir}/#{filename}.part already exists"

		if File.exists?("#{upload_dir}/#{filename}.part") then
			current_filesize = File.size("#{upload_dir}/#{filename}.part")
			puts "it exists!"
			puts "size: #{current_filesize}"
		else
			current_filesize = 0
			puts "it doesn't exists"
		end

		return {size: current_filesize, name: filename}
	end
end