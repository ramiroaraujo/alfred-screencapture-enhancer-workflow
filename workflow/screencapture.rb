require_relative 'workflow_config'

command = ARGV[0]
config = WorkflowConfig.new.config

# calculate command line options for screencapture
config_flags = "-t #{config['format']}#{ ' -0' unless config['shadow']}"
date = `date "+%Y-%m-%d at %H.%M.%S"`.chomp "\n"
filename = File.expand_path("#{config['location'].chomp '/'}/#{config['name']} #{date}.#{config['format']}")

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

# write extra metadata to file
def write_attributes(filename)
  `xattr -wx com.apple.metadata:kMDItemIsScreenCapture '62706C697374303009080000000000000101000000000000000100000000000000000000000000000009' "#{filename}"`
  `xattr -w com.apple.metadata:kMDItemScreenCaptureType 'selection' "#{filename}"`
  `mdimport "#{filename}"`
end

# @todo add option to specify name if called within alfred's keyword instead of shortcut
case command
  when 'area'
    `/usr/sbin/screencapture #{config_flags} -i "#{filename}"`
  when 'area-clipboard'
    `/usr/sbin/screencapture #{config_flags} -i -c "#{filename}"`
  when 'last-area'
    `/usr/sbin/screencapture #{config_flags} -c #{area}`
    `./pbpaste-image > "#{filename}"`
    `/usr/bin/afplay Grab.aif`
    write_attributes(filename)
  when 'last-area-clipboard'
    `/usr/sbin/screencapture #{config_flags} -c #{area}`
    `/usr/bin/afplay Grab.aif`
    write_attributes(filename)
end