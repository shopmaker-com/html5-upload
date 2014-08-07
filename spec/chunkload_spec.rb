require 'minitest/autorun'

require_relative "../app/chunkload.rb"
require_relative './spec_helper.rb'

describe Chunkload do
	
	describe "target_partialfile_name" do
		it "adds .part at the end of the filename, and adds dir to the front" do
			tpfn = Chunkload.target_partialfile_name("directory", "file")

			tpfn.must_equal "directory/file.part"
		end
	end

	describe "append_chunk" do

		it "appends a file chunk to the existing file" do
			#create chunk, and an existing file
			create_file("./test.txt", "source")
			create_file("./test.txt.part", "target")

			Chunkload.append_chunk('./test.txt', '.', 'test.txt')

			result = File.read("./test.txt.part")

			result.must_equal "targetsource" #concatenated content of a chunk and a target file

			#cleanup
			File.unlink('./test.txt')
			File.unlink('./test.txt.part')
		end

		it "creates a partial file, when there is no existing file" do
			create_file("./test.txt", "source")

			Chunkload.append_chunk('./test.txt', '.', 'test.txt')

			File.exists?('./test.txt.part').must_equal true

			#cleanup
			File.unlink('./test.txt.part')
		end
	end

	describe "upload_chunk" do

		before do
			random_name = rand.to_s
			@chunk = mock_upload("./#{random_name}", 'firstchunk')
			@upload_dir = "uploads_test_#{rand.to_s}" #random upload dir name
			Dir.mkdir(@upload_dir)
		end


		it "uploads the chunk" do
			# mock upload half of the file
			content_range = create_content_range(0, @chunk[:tempfile].size/2, @chunk[:tempfile].size) 
			

			Chunkload.upload_chunk(@chunk, content_range, @upload_dir)

			File.exists?("#{@upload_dir}/#{@chunk[:filename]}.part").must_equal true
		end

		it "doesn't upload an allready uploaded chunk" do
			#upload once
			content_range = create_content_range(0, @chunk[:tempfile].size/2, @chunk[:tempfile].size) 
			Chunkload.upload_chunk(@chunk, content_range, @upload_dir)

			#attempt to upload the same chunk again
			content_range = create_content_range(0, @chunk[:tempfile].size/2, @chunk[:tempfile].size) 
			Chunkload.upload_chunk(@chunk, content_range, @upload_dir)

			#partial file must not have the size doubled
			File.size?("#{@upload_dir}/#{@chunk[:filename]}.part").must_equal @chunk[:tempfile].size
		end

		it "corrects the filename when the last chunk is uploaded" do
			#mock upload the whole file
			content_range = create_content_range(0, @chunk[:tempfile].size-1, @chunk[:tempfile].size) 

			Chunkload.upload_chunk(@chunk, content_range, @upload_dir)	

			File.exists?("#{@upload_dir}/#{@chunk[:filename]}").must_equal true #without .part at the end!

			#cleanup
			File.unlink("#{@upload_dir}/#{@chunk[:filename]}")
		end

		#cleanup
		after do
			File.unlink(@chunk[:tempfile])
			if File.exists?("#{@upload_dir}/#{@chunk[:filename]}.part")
				File.unlink("#{@upload_dir}/#{@chunk[:filename]}.part")
			end

			Dir.unlink(@upload_dir)
		end
	end

	describe "check" do
		before do
			@random_name = rand.to_s
			@upload_dir = "uploads_test_#{rand.to_s}" #random upload dir name
			Dir.mkdir(@upload_dir)
			#file must have .part at the end, because Chunkfile.check() only checks existing uploads, not finished files
			create_file("#{@upload_dir}/#{@random_name}.part", "testfile")
		end

		it "returns an array with filesize and filename" do
			expected = {size: File.size("#{@upload_dir}/#{@random_name}.part"), name: @random_name}
			result = Chunkload.check(@upload_dir, @random_name)

			result.must_equal expected
		end

		after do
			File.unlink("#{@upload_dir}/#{@random_name}.part")
			Dir.unlink(@upload_dir)
		end
	end
end