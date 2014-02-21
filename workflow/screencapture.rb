# tomar config

require_relative 'bundle/bundler/setup'
require_relative 'workflow_config'

command      = ARGV[0]
config       = WorkflowConfig.new.config

# calculate command line options for screencapture
config_flags = "-t #{config['format']}#{ ' -0' unless config['shadow']}"
date         = `date "+%Y-%m-%d at %H.%M.%S"`.chomp "\n"
filename     = File.expand_path("#{config['location'].chomp '/'}/#{config['name']} #{date}.#{config['format']}")

# read previous coordinates if existent and needed
if command =~ /^last/

  # play error sound if no previous coordinates are available and exit
  unless File.exist? 'coordinates.txt'
    `/usr/bin/afplay /System/Library/Sounds/Funk.aiff`
    exit 1
  end

  # read coordinates
  x_ini, x_end, y_ini, y_end = IO.read('coordinates.txt').split(' ')
  coordinates = {
      x: x_ini < x_end ? x_ini : x_end,
      y: y_ini < y_end ? y_ini : y_end,

  }

  puts 'listo'

end

case command
  when 'area'
    `/usr/sbin/screencapture #{config_flags} -i "#{filename}"`
  when 'area-clipboard'
    `/usr/sbin/screencapture #{config_flags} -i -c "#{filename}"`
  when 'last-area'
    puts 'nada'
  when 'last-area-clipboard'
    puts 'nada'
end