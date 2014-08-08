ENV['RACK_ENV'] = 'test'

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start
end

require 'minitest/autorun'
require_relative '../models/chunk.rb'

def create_file(filepath, contents)
  File.open(filepath, 'w') {|f| f.write(contents) }
end

# returns the formatted content-range header
def create_content_range(first_byte, last_byte, total)
 "#{first_byte}-#{last_byte}/#{total}"
end

def mock_upload(filepath, contents)
  create_file(filepath, contents)
  result = {}

  result[:tempfile] = File.new(filepath, 'r')
  result[:filename] = File.basename(filepath)

  result
end

def compare_files(file1, file2)
  FileUtils.compare_file(file1, file2)
end
