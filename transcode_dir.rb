#!/usr/bin/env ruby
require 'fileutils'

class MkvToMp4
  def initialize(input, output)
    @input = input
    @output = output
  end

  def perform()
    `HandBrakeCLI --preset "High Profile" -i "#{@input}" -o "#{@output}"`
    {input_file: @input, output_file: @output}
  end
end

def usage
  puts 'transcode_dir.rb title'
  exit
end

usage() if ARGV.count < 1

SOURCE_DIR = '/mkv/'
CONVERSION_DIR = '/videos/'

title = ARGV.first.gsub(/[ ':\/\\]+/, "_")
output_dir = File.join(CONVERSION_DIR, title)
FileUtils.mkdir_p(output_dir)

input_files = Dir.glob(File.join(SOURCE_DIR, title, "**"))
input_files.each do |input|
  output = input.gsub(SOURCE_DIR, CONVERSION_DIR).gsub('.mkv', '.mp4')
  MkvToMp4.new(input, output).perform
end

