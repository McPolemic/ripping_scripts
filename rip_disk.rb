#!/usr/bin/env ruby
require "logger"
require "optparse"
require "rakemkv"

# Rips a DVD/Blu-Ray. Returns when done. No muss. No fuss.
OUTPUT_DIR = '/mkv/'

STDOUT.sync = true
logger = Logger.new(STDOUT)

class TranscodesAllTitles
  def initialize(disc_device: "/dev/sr0")
    @disc_device = disc_device
  end

  def perform()
    disc = RakeMKV::Disc.new(@disc_device)
    titles = disc.titles

    titles.each do |title|
      logger.info("Ripping title #{title.id}, length: #{title.duration}, #{title.chapter_count} chapters...")
      disc.transcode!(title_id: title.id)
    end
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
ripped_file = TranscodesAllTitles.new(disc_device: disc).perform()
logger.info("Finished rip. The following files were created:")
Dir.glob(File.join(DIRECTORY_NAME, '**')).each do |file|
  logger.info("* #{file}")
end


