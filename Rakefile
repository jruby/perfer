require 'path'

desc 'Update the README with usage'
task :update_readme do
  usage_tag = '<!-- usage -->'
  usage = `bin/perfer help`
  Path.relative('README.md').rewrite do |contents|
    replace = "#{usage_tag}\n```text\n#{usage}```\n#{usage_tag}"
    contents.sub(/#{usage_tag}.*#{usage_tag}/m, replace)
  end
end

desc 'Run the specs'
task :spec do
  require 'rspec'
  exit RSpec::Core::Runner.run(%w[--color spec])
end

task :default => :spec
