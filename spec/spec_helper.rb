ENV['RACK_ENV'] = 'test'

if ENV['COVERAGE']
  require 'simplecov'
  SimpleCov.start
end

require 'minitest/autorun'
require 'sinatra'
require 'sinatra/config_file'
require_relative '../models/chunk.rb'

config_file '../config/config.yml'

def create_file(filepath, contents)
  File.open(filepath, 'w').tap {|f| f.write(contents) }
end

def create_content_range(first_byte, last_byte, total)
 "#{first_byte}-#{last_byte}/#{total}"
end

def cleanup
  FileUtils.rm(Dir.glob('tmp/test*'))
end
