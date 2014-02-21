require 'yaml'

class WorkflowConfig

  attr_accessor :config

  @config

  def initialize
    load_config
  end

  def load_config
    @config = YAML.load File.open 'config.yml'

    unless @config
      @config = { format: 'png', location: '~/Downloads', name: 'Screen Shot', shadow: 1 } if !@config
      File.open('config.yml', 'w') { |f| f.write(@config.to_yaml) }
    end
  end

  private :load_config
end