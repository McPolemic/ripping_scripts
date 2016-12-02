#!/usr/bin/env ruby
require "logger"
require "optparse"
require "rakemkv"

# Rips a DVD/Blu-Ray. Returns when done. No muss. No fuss.
OUTPUT_DIR = '/mkv/'

STDOUT.sync = true
logger = Logger.new(STDOUT)

class Ripper
  attr_reader :disk

  def initialize(disk_device: "/dev/sr0", title_id: nil, logger:)
    @disk = RakeMKV::Disc.new(disk_device)
    @title_id = title_id.to_i
    @logger = logger
  end

  def rip()
    @title_id = titles.longest.id if @title_id == -1

    if @title_id
      rip_title
    else
      rip_disk
    end
  end

  def rip_disk
    titles.each do |title|
      @logger.info("Ripping title #{title.id}, #{title.chapter_count} chapters...")
      disk.transcode!(title_id: title.id)
    end
  end

  def rip_title
    @logger.info("Ripping title #{@title_id}...")
    disk.transcode!(title_id: @title_id)
  end

  def titles
    @titles ||= @disk.titles
  end
end

options = {}

# Set up defaults
options[:title] = ENV.fetch('RIP_TITLE', nil)
options[:title_id] = ENV.fetch('RIP_TITLE_ID', nil)
options[:disk] = ENV.fetch('RIP_DISC', "/dev/sr0")

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: #{$0} [options]"

  opts.on("-d", "--disk /dev/sr0", "Set the disk device") do |disk|
    options[:disk] = disk
  end

  opts.on("-t", "--title TITLE", "Set the title of the movie") do |title|
    options[:title] = title
  end

  opts.on("-i", "--index NUM", "Rip the specified title ID. Set to -1 to rip the longest title.") do |num|
    options[:title_id] = num
  end

  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    puts <<~EOF
    Options can also be set with the following environment variables:
      * RIP_TITLE
      * RIP_TITLE_ID
      * RIP_DISC_DEVICE
    EOF
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
disk = options[:disk]
title_id = options[:title_id]

ripper = Ripper.new(disk_device: disk, title_id: title_id, logger: logger).rip

logger.info("Finished rip. The following files were created:")
Dir.glob(File.join(DIRECTORY_NAME, '**')).each do |file|
  logger.info("* #{file}")
end


