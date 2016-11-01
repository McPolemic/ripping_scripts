require "logger"

def usage
  puts 'rip_bluray.rb "Title in Quotes"'
  exit
end

# Utility functions
def find_newest_file(directory)
  Dir.glob("#{directory}/*").max_by {|f| File.mtime(f)}
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

def main
  usage() if ARGV.count < 1 || ARGV.first == "-h" || ARGV.first == "--help"

  output_dir = '/home/adam/Videos/'
  conversion_dir = '/home/adam/Converted/'
  title = ARGV.first
  directory_name = File.join(output_dir, title.gsub(/[ ':\/\\]+/, "_"))

  STDOUT.sync = true
  logger = Logger.new(STDOUT)

  ripped_file = find_newest_file(directory_name)

  logger.info("Beginning transcode of #{ripped_file}.")
  output_name = File.join(directory_name, "#{title}.mp4")
  output = MkvToMp4.new(ripped_file, output_name).perform
  logger.info("Finished transcode.")

  logger.info("Moving completed file to conversion directory.")
  `mv "#{output_name}" "#{conversion_dir}"`
  logger.info("Finished processing.")
end

if $0 == __FILE__
  main
end
