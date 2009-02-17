# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{xmlrpc_annotations}
  s.version = "1.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Alex Young"]
  s.date = %q{2009-02-17}
  s.default_executable = %q{xmlrpc_annotations}
  s.description = %q{A library for adding annotations to XMLRPC server classes that allows autogeneration of C# interface files for use with the XMLRPC.NET library.}
  s.email = %q{alex@blackkettle.org}
  s.executables = ["xmlrpc_annotations"]
  s.extra_rdoc_files = ["History.txt", "README.txt", "bin/xmlrpc_annotations"]
  s.files = ["History.txt", "README.txt", "Rakefile", "bin/xmlrpc_annotations", "lib/xmlrpc/annotations.rb", "lib/xmlrpc_annotations.rb", "spec/spec_helper.rb", "spec/xmlrpc_annotations_spec.rb", "test/test_xmlrpc_annotations.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/regularfry/xmlrpc_annotations}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{xmlrpc_annotations}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{A library for adding annotations to XMLRPC server classes that allows autogeneration of C# interface files for use with the XMLRPC}
  s.test_files = ["test/test_xmlrpc_annotations.rb"]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<activesupport>, [">= 2.2.2"])
      s.add_development_dependency(%q<bones>, [">= 2.4.0"])
      s.add_development_dependency(%q<minitest>, [">= 1.3.0"])
    else
      s.add_dependency(%q<activesupport>, [">= 2.2.2"])
      s.add_dependency(%q<bones>, [">= 2.4.0"])
      s.add_dependency(%q<minitest>, [">= 1.3.0"])
    end
  else
    s.add_dependency(%q<activesupport>, [">= 2.2.2"])
    s.add_dependency(%q<bones>, [">= 2.4.0"])
    s.add_dependency(%q<minitest>, [">= 1.3.0"])
  end
end
