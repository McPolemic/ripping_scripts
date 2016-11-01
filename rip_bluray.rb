require "logger"
require "optparse"
require "rakemkv"

# Rips a DVD/Blu-Ray. Returns when done. No muss. No fuss.
OUTPUT_DIR = '/home/adam/Videos/'
CONVERSION_DIR = '/home/adam/Converted/'

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
      disc.transcode!(title_id: @title_id)
    else
      disc.transcode!(title_id: titles.longest.id)
    end

    return find_newest_file(DIRECTORY_NAME)
  end
end

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
  puts 'rip_bluray.rb "Title in Quotes" <Track Number>'
  exit
end

options = {}

optparse = OptionParser.new do |opts|
  opts.banner = "Usage: ruby2.0 rip_bluray.rb [options]"

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

TITLE = options[:title]
usage() unless TITLE
DIRECTORY_NAME = File.join(OUTPUT_DIR, TITLE.gsub(/[ ':\/\\]+/, "_"))
RakeMKV.config.destination = DIRECTORY_NAME
logger.info("Creating directory #{DIRECTORY_NAME}.")
Dir.mkdir(DIRECTORY_NAME)

logger.info("Beginning rip.")
title_id = options[:title_id]
ripped_file = TranscodesLongestTitle.new(title_id: title_id).perform()
logger.info("Finished rip. New file is #{ripped_file}.")
`eject`
`/home/adam/src/scripts/pushover.sh "Blu-Ray rip finished"`

logger.info("Beginning transcode of #{ripped_file}.")
OUTPUT_NAME = File.join(DIRECTORY_NAME, "#{TITLE}.mp4")
output = MkvToMp4.new(ripped_file, OUTPUT_NAME).perform
logger.info("Finished transcode.")

logger.info("Moving completed file to conversion directory.")
`mv "#{OUTPUT_NAME}" "#{CONVERSION_DIR}"`
logger.info("Finished processing.")
