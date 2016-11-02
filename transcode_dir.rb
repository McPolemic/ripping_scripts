#!/usr/bin/env ruby
require_relative './transcode'
require 'fileutils'

def usage
  puts 'transcode_dir.rb /path/to/input/dir/ /path/to/output/dir/'
  exit
end

usage() if ARGV.count < 2

source_dir = ARGV[0]
conversion_dir = ARGV[1]

FileUtils.mkdir_p(conversion_dir)

input_files = Dir.glob(File.join(source_dir, "**"))
input_files.each do |input|
  output = input.gsub(source_dir, conversion_dir).gsub('.mkv', '.mp4')
  MkvToMp4.new(input, output).perform
end

