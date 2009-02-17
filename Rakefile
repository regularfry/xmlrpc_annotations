# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

begin
  require 'bones'
  Bones.setup
rescue LoadError
  begin
    load 'tasks/setup.rb'
  rescue LoadError
    raise RuntimeError, '### please install the "bones" gem ###'
  end
end

ensure_in_path 'lib'
require 'xmlrpc_annotations'

task :default => 'test'

PROJ.name = 'xmlrpc_annotations'
PROJ.authors = 'Alex Young'
PROJ.email = 'alex@blackkettle.org'
PROJ.url = 'http://github.com/regularfry/xmlrpc_annotations'
PROJ.version = XmlrpcAnnotations::VERSION
PROJ.rubyforge.name = 'xmlrpc_annotations'
PROJ.gem.dependencies << ['activesupport', '>= 2.2.2']
PROJ.gem.development_dependencies << ['minitest', '>= 1.3.0']

PROJ.spec.opts << '--color'

# EOF
