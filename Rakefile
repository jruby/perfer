require 'path'

task :update_readme do
  usage_tag = '<!-- usage -->'
  usage = `bin/perfer help`
  Path.relative('README.md').rewrite do |contents|
    replace = "#{usage_tag}\n```text\n#{usage}```\n#{usage_tag}"
    contents.sub(/#{usage_tag}.*#{usage_tag}/m, replace)
  end
end
