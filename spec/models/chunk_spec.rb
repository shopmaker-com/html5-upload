require_relative '../spec_helper.rb'

describe Chunk do
  describe 'initialization' do
    after {cleanup}

    it 'initializes a chunk to be uploaded' do
      @filename = Tempfile.new
      chunk = Chunk.new(File.dirname(@filename), File.basename(@filename))
      chunk.file_name.must_equal(File.basename(@filename))
    end
  end

  describe 'upload' do
    after {cleanup}

    it 'raises when http_content_rage is not set properly' do
      @filename = 'tmp/test.txt'
      @tempfile = create_file('tmp/test-chunk', '123')
      chunk = Chunk.new(File.dirname(@filename), File.basename(@filename))

      error = -> {
        chunk.upload(@tempfile, '')
      }.must_raise RuntimeError
      error.message.must_match('http_content_rage is not set')

      error = -> {
        chunk.upload(@tempfile, '1-0/2')
      }.must_raise RuntimeError
      error.message.must_match('http_content_rage contains zero')

      error = -> {
        chunk.upload(@tempfile, '1-1/0')
      }.must_raise RuntimeError
      error.message.must_match('http_content_rage contains zero')
    end

    it 'starts upload' do
      @filename = 'tmp/test.txt'
      @tempfile = create_file('tmp/test-chunk', '123')
      chunk = Chunk.new(File.dirname(@filename), File.basename(@filename))

      content_range = create_content_range(0, @tempfile.size - 1, @tempfile.size)
      content_range.must_equal '0-2/3'

      result = chunk.upload(@tempfile.path, content_range)
      result.must_equal({name: 'test.txt', size: 3, uploadedBytes: 2, complete: true})

      result = File.read(@filename)
      result.must_equal '123'
    end

    it 'appends target to source' do
      @filename = 'tmp/test.txt'
      @tempfile = create_file('tmp/test-chunk', '45678')
      chunk = Chunk.new(File.dirname(@filename), File.basename(@filename))

      @partfile = create_file('tmp/test.txt.part', '123')
      content_range = create_content_range(@partfile.size, @partfile.size + @tempfile.size - 1, @partfile.size + @tempfile.size)
      content_range.must_equal '3-7/8'

      result = chunk.upload(@tempfile.path, content_range)
      result.must_equal({name: 'test.txt', size: 8, uploadedBytes: 7, complete: true})

      result = File.read(@filename)
      result.must_equal '12345678'
    end

    it 'appends target to source multiple times' do
      @filename = 'tmp/test.txt'
      @tempfile = []
      @tempfile << create_file('tmp/test-chunk1', '123')
      @tempfile << create_file('tmp/test-chunk2', '45678')
      @tempfile << create_file('tmp/test-chunk3', '789910123')
      chunk = Chunk.new(File.dirname(@filename), File.basename(@filename))

      total_size = @tempfile.sum {|file| file.size}
      total_size.must_equal 17

      content_range = create_content_range(0, @tempfile[0].size - 1, total_size)
      content_range.must_equal '0-2/17'
      result = chunk.upload(@tempfile[0].path, content_range)
      result.must_equal({name: 'test.txt', size: 17, uploadedBytes: 2, complete: false})

      content_range = create_content_range(2, @tempfile[0].size + @tempfile[1].size - 1, total_size)
      content_range.must_equal '2-7/17'
      result = chunk.upload(@tempfile[1].path, content_range)
      result.must_equal({name: 'test.txt', size: 17, uploadedBytes: 7, complete: false})

      content_range = create_content_range(5, @tempfile[0].size + @tempfile[1].size + @tempfile[2].size - 1, total_size)
      content_range.must_equal '5-16/17'
      result = chunk.upload(@tempfile[2].path, content_range)
      result.must_equal({name: 'test.txt', size: 17, uploadedBytes: 16, complete: true})

      result = File.read(@filename)
      result.must_equal '12345678789910123'
    end
  end
end
