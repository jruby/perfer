require 'spec_helper'
require 'cgi'

describe 'perfer integration tests' do
  let(:bench) { Path('spec/fixtures/bench') }
  let(:output) { Path('spec/integration/output') }

  before(:each) do
    Perfer.stub(:measure => {:real => 0.1})
  end

  def output_path(args)
    args.map! { |arg| arg.to_s.sub('spec/fixtures/bench/', '') }
    path = CGI.escape args.join(' ')
    (output/path).add_ext('txt')
  end

  def test_output(*args)
    out, err = perfer(*args)
    err.should be_empty

    out.sub!(RUBY_DESCRIPTION, '<ruby>')

    path = output_path(args)
    path.write(out) if ENV['INTEGRATION_FIRST_RUN']

    out.should == path.read
  end

  it 'run iterative.rb' do
    test_output 'run', bench/'iterative.rb'
  end
end
