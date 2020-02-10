#!/usr/bin/env ruby
require 'optparse'
# install the following gems
require 'faraday'
require 'oj'
require 'down'

options = {
  feed_id: nil,
  date: nil,
  name: nil,
  username: nil,
  password: nil
}

OptionParser.new do |opts|
  opts.on("-fFEED", "--feed=FEED", "Feed ID") do |f|
    options[:feed_id] = f
  end
  opts.on("-dDATE", "--date=DATE", "Archives Date YYYY-MM-DD") do |d|
    options[:date] = d
  end
  opts.on("-sSHORTNAME", "--shortname=SHORTNAME", "Short Feed Name") do |s|
    options[:shortname] = s
  end
  opts.on("-nNAME", "--name=NAME", "Extended Feed Name") do |n|
    options[:name] = n
  end
  opts.on("-uUSERNAME", "--username=USERNAME", "Broadcastify Username") do |u|
    options[:username] = u
  end
  opts.on("-pPASSWORD", "--password=PASSWORD", "Broadcastify Password") do |p|
    options[:password] = p
  end
end.parse!

# Assign vars from args
username = options[:username]
password = options[:password]
feed_id = options[:feed_id]
feed_shortname = options[:shortname]
feed_name = options[:name]

# API Archive Listing
api_host = "https://api.broadcastify.com/owner/?type=json&a=archives"
api_date = options[:date] #YYYY-MM-DD
api_url = "#{api_host}&feedId=#{feed_id}&day=#{api_date}&u=#{username}&p=#{password}"
year = api_date.split("-")[0]

# Download Archives
download_host = "https://garchives1.broadcastify.com"
download_date = api_date.delete '-' #YYYYMMDD
download_base_url = "#{download_host}/#{feed_id}/#{download_date}"

# Create temp output dir for single mp3 files
tmp_output_path = "#{feed_id}_#{download_date}"
Dir.mkdir(tmp_output_path) unless File.exists?(tmp_output_path)

# Create archives folder for final output if doesn't exist
output_path = "archives"
Dir.mkdir(output_path) unless File.exists?(output_path)

# Call API and parse JSON response
response = Faraday.get api_url
archives_body = Oj.load(response.body)
archives = archives_body["archives"].reverse

# Iterate through archive objects and download files
cnt = 1
archives.each do |archive|
  archive_name = archive["archive"]
  file_name = archive["url"].split("http:////")[1]
  full_url = "#{download_base_url}/#{file_name}"
  zcnt = "%05d" % cnt
  new_name = "#{zcnt}.mp3"
  filename = "#{tmp_output_path}/#{new_name}"
  
  io = Down.open(full_url, rewindable: false)
  IO.copy_stream(io, filename)
  io.close

  # check if file is at least greater than 75 kB to keep it
  if File.size(filename) > 75000
    puts "Saved #{archive_name}"
    cnt += 1
  else
    puts "Skipping #{archive_name}"
    File.delete(filename)
  end
end

# sudo apt-get install mp3wrap
# concat all the mp3 files together
output_file = "#{output_path}/#{feed_shortname}_#{download_date}"
`mp3wrap #{output_file}.mp3 #{tmp_output_path}/*.mp3`

# rename the output file
File.rename("#{output_file}_MP3WRAP.mp3", "#{output_file}.mp3")

# remove individual files
FileUtils.remove_dir(tmp_output_path,true)

# sudo apt-get install id3v2
# set the mp3 tags for the file
title = "#{feed_shortname} #{api_date}"
`id3v2 -D #{output_file}.mp3`
`id3v2 -t \"#{title}\" -A \"#{feed_name}\" -a \"#{username.upcase}\" -y \"#{year}\" #{output_file}.mp3`

puts "File processed sucessfully: #{output_file}.mp3"