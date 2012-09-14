Gem::Specification.new do |s|
  s.name = 'perfer'
  s.summary = 'A benchmark tool for all rubies!'
  s.author = 'eregon'
  s.email = 'eregontp@gmail.com'
  s.homepage = 'https://github.com/jruby/perfer'
  s.files = Dir['bin/*'] + Dir['lib/**/*.rb'] + %w[README.md LICENSE perfer.gemspec]
  s.executables << 'perfer'
  s.add_dependency 'path', '~> 1.3.1'
  s.add_dependency 'ffi', '~> 1.0.11'
  s.add_dependency 'backports', '~> 2.6.3'
  s.add_dependency 'hitimes', '~> 1.1.1'
  s.version = '0.2.0'
end
