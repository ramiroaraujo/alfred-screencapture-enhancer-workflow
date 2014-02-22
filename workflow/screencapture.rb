require_relative 'workflow_config'

command = ARGV[0]
name = ARGV[1].to_s
config = WorkflowConfig.new.config

# calculate command line options for screencapture
config_flags = "-t #{config['format']}#{ ' -o' unless config['shadow'] == 1}"
date = `date "+%Y-%m-%d at %H.%M.%S"`.chomp "\n"
filename = !(name =~ /^[[:space:]]*$/) ? name : "#{config['name']} #{date}"
filepath = File.expand_path("#{config['location'].chomp '/'}/#{filename}.#{config['format']}")

# read previous coordinates if existent and needed
if command =~ /^last/

  # play error sound if no previous coordinates are available and exit
  unless File.exist? 'coordinates'
    `/usr/bin/afplay /System/Library/Sounds/Funk.aiff`
    exit 1
  end

  # read coordinates
  x_ini, x_end, y_ini, y_end = IO.read('coordinates').split(' ').map(&:to_i)
  coordinates = {
      x: x_ini < x_end ? x_ini : x_end,
      y: y_ini < y_end ? y_ini : y_end,
      width: x_ini < x_end ? x_end - x_ini : x_ini - x_end,
      height: y_ini < y_end ? y_end - y_ini : y_ini - y_end,
  }

  area = "-R '#{coordinates[:x]},#{coordinates[:y]},#{coordinates[:width]},#{coordinates[:height]}'"
end

# write extra metadata to file, I believe only to help the quick view render screenshots correctly in retina displays
def write_attributes(filename)
  `xattr -wx com.apple.metadata:kMDItemIsScreenCapture '62706C697374303009080000000000000101000000000000000100000000000000000000000000000009' "#{filename}"`
  `xattr -w com.apple.metadata:kMDItemScreenCaptureType 'selection' "#{filename}"`
  `mdimport "#{filename}"`
end

case command
  when 'area'
    `/usr/sbin/screencapture #{config_flags} -i "#{filepath}"`
  when 'area-clipboard'
    `/usr/sbin/screencapture #{config_flags} -i -c "#{filepath}"`
  when 'last-area'
    `/usr/sbin/screencapture #{config_flags} -c #{area}`
    `./pbpaste-image > "#{filepath}"`
    `/usr/bin/afplay Grab.aif`
    write_attributes(filepath)
  when 'last-area-clipboard'
    `/usr/sbin/screencapture #{config_flags} -c #{area}`
    `/usr/bin/afplay Grab.aif`
    write_attributes(filepath)
end