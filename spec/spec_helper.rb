require File.expand_path('../../lib/perfer', __FILE__)
require 'rspec'
require 'stringio'

module Perfer
  remove_const :DIR
  DIR = Path.relative('fixtures/saved')
  Perfer.reset
end

module PerferSpecHelper
  include RSpec::Matchers

  def capture_io
    stdout, stderr = $stdout, $stderr
    $stdout, $stderr = StringIO.new, StringIO.new
    begin
      yield
    rescue
      stdout.puts "stdout:\n>>>#{$stdout.string}<<<"
      stdout.puts "stderr:\n>>>#{$stderr.string}<<<"
      raise $!
    end
    out, err = $stdout.string, $stderr.string
    if RUBY_DESCRIPTION.start_with?('jruby') and JRUBY_VERSION < "1.7" and RUBY_VERSION > "1.9"
      out.force_encoding Encoding::UTF_8
      err.force_encoding Encoding::UTF_8
    end
    [out, err]
  ensure
    $stdout, $stderr = stdout, stderr
  end

  def raise_perfer_error(error)
    raise_error(Perfer::Error, Perfer::Errors.const_get(error))
  end

  def perfer(*args)
    capture_io do
      Perfer::CLI.new(args).execute
    end
  end

  def stub_job_run
    Perfer::IterationJob.any_instance.stub(:run) {}
    Perfer::InputSizeJob.any_instance.stub(:run) {}
  end
end

RSpec.configure do |c|
  c.include PerferSpecHelper
  c.after(:suite) do
    Path.relative('fixtures/saved/results').rm_rf
  end
end
