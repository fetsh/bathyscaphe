# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "bathyscaphe/version"

Gem::Specification.new do |s|
  s.name        = "bathyscaphe"
  s.version     = Bathyscaphe::VERSION
  s.authors     = ["Ilia Zemskov"]
  s.email       = ["il.zoff@gmail.com"]
  s.homepage    = "https://github.com/ilzoff/bathyscaphe"
  s.summary     = %q{Simple gem to download subtitles from addic7ed.com}
  s.description = %q{Simple gem to download subtitles for tv-show episodes from addic7ed.com. Subtitles are searched based on file name.}

  s.rubyforge_project = "bathyscaphe"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_runtime_dependency "nokogiri"
end
