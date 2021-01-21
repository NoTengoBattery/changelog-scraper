#!/usr/bin/env ruby

require_relative 'environment'
Bundler.require(:test)

config = RSpec::Core::ConfigurationOptions.new(
  ['--format', 'documentation',
   '--force-color',
   '--pattern', 'spec/**/*_spec.rb',
   '--bisect=verbose']
)
runner = RSpec::Core::Runner.new(config)
runner.run($stderr, $stdout)
