require 'workflow_config'

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
      :x => x_ini < x_end ? x_ini : x_end,
      :y => y_ini < y_end ? y_ini : y_end,
      :width => x_ini < x_end ? x_end - x_ini : x_ini - x_end,
      :height => y_ini < y_end ? y_end - y_ini : y_ini - y_end,
  }

  area = "-R '#{coordinates[:x]},#{coordinates[:y]},#{coordinates[:width]},#{coordinates[:height]}'"
end

case command
  when 'area'
    `/usr/sbin/screencapture #{config_flags} -i "#{filepath}"`
  when 'area-clipboard'
    `/usr/sbin/screencapture #{config_flags} -i -c "#{filepath}"`
  when 'last-area'
    `/usr/sbin/screencapture #{config_flags} #{area}`
    `mv #{area[3..-1]} "#{filepath}"`
    `/usr/bin/afplay Grab.aif`
  when 'last-area-clipboard'
    `/usr/sbin/screencapture #{config_flags} -c #{area}`
    `/usr/bin/afplay Grab.aif`
  when 'screen'
    `/usr/sbin/screencapture #{config_flags} "#{filepath}"`
  when 'screen-clipboard'
    `/usr/sbin/screencapture #{config_flags} -c`
end