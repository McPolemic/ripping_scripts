#!/usr/bin/env ruby
require "logger"
require "optparse"
require "rakemkv"

# Rips a DVD/Blu-Ray. Returns when done. No muss. No fuss.
OUTPUT_DIR = '/mkv/'

STDOUT.sync = true
logger = Logger.new(STDOUT)

# Utility functions
def find_newest_file(directory)
  Dir.glob("#{directory}/*").max_by {|f| File.mtime(f)}
end

class TranscodesLongestTitle
  def initialize(disc_device: "/dev/sr0", title_id: nil)
    @disc_device = disc_device
    @title_id = title_id
  end

  def perform()
    disc = RakeMKV::Disc.new(@disc_device)
    titles = disc.titles

    if @title_id
      logger.info("Ripping title #{@title_id}...")
      disc.transcode!(title_id: @title_id)
    else
      title = titles.longest
      logger.info("Ripping title #{title.id}, length: #{title.duration}, #{title.chapter_count} chapters...")
      disc.transcode!(title_id: title.id)
    end

    return find_newest_file(DIRECTORY_NAME)
  end
end

options = {}

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [options]"

  options[:disc] = "/dev/sr0"
  opts.on("-d", "--disc /dev/sr0", "Set the disc device") do |disc|
    options[:disc] = disc
  end

  options[:title] = nil
  opts.on("-t", "--title TITLE", "Set the title of the movie") do |title|
    options[:title] = title
  end

  options[:title_id] = nil
  opts.on("-i", "--index NUM", "Rip the specified title ID") do |num|
    options[:title_id] = num
  end

  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end

optparse.parse!

unless options[:title]
  puts "Requires title. See -h for more information"
  exit
end

DIRECTORY_NAME = File.join(OUTPUT_DIR, options[:title].gsub(/[ ':\/\\]+/, "_"))
logger.info("Creating directory #{DIRECTORY_NAME}.")
Dir.mkdir(DIRECTORY_NAME) unless Dir.exist?(DIRECTORY_NAME)
logger.info("Outputting to #{DIRECTORY_NAME}")
RakeMKV.config.destination = DIRECTORY_NAME

logger.info("Beginning rip.")
disc = options[:disc]
title_id = options[:title_id]
ripped_file = TranscodesLongestTitle.new(disc_device: disc, title_id: title_id).perform()
logger.info("Finished rip. New file is #{ripped_file}.")

