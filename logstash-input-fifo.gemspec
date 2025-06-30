Gem::Specification.new do |s|
  s.name          = 'logstash-input-fifo'
  s.version       = '0.9.4'
  s.licenses      = ['Apache License (2.0)']
  s.summary       = 'Read events out of a static file or from a named pipe'
  s.description   = 'This gem is a Logstash plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/logstash-plugin install gemname. This gem is not a stand-alone program'
  s.homepage      = 'https://github.com/atnak/logstash-input-fifo'
  s.authors       = ['Atsushi Nakagawa']
  s.email         = 'atnak@chejz.com'
  s.require_paths = ['lib']

  # Files
  s.files = Dir['lib/**/*','spec/**/*','vendor/**/*','*.gemspec','*.md','CONTRIBUTORS','Gemfile','LICENSE','NOTICE.TXT']
   # Tests
  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  # Special flag to let us know this is actually a logstash plugin
  s.metadata = { "logstash_plugin" => "true", "logstash_group" => "input" }

  # Gem dependencies
  s.add_runtime_dependency "logstash-core-plugin-api", "~> 2.0"
  s.add_runtime_dependency 'logstash-codec-line'
  s.add_runtime_dependency 'logstash-mixin-ecs_compatibility_support', '~> 1.2'

  s.add_development_dependency 'logstash-devutils', '>= 0.0.16'
  s.add_development_dependency "logstash-codec-plain"
  s.add_development_dependency "logstash-codec-json"
  s.add_development_dependency "logstash-codec-json_lines"
end
