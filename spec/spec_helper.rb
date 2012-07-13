require File.expand_path('../../lib/perfer', __FILE__)
require 'rspec'

module PerferSpecHelper
  include RSpec::Matchers

  def raise_perfer_error(error)
    raise_error(Perfer::Error, Perfer::Errors.const_get(error))
  end
end

RSpec.configure do |c|
  c.include PerferSpecHelper
end
