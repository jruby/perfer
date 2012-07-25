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
    yield
    [$stdout.string, $stderr.string]
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
end

RSpec.configure do |c|
  c.include PerferSpecHelper
  c.after(:suite) do
    Path.relative('fixtures/saved/results').rm_r
  end
end
