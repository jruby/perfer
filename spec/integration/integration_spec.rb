require 'spec_helper'
require 'cgi'

describe 'perfer integration tests' do
  let(:bench) { Path('spec/fixtures/bench') }
  let(:output) { Path('spec/integration/output') }

  before(:each) do
    Perfer.stub(:measure) { { :real => 0.1 } }
  end

  after(:each) do
    Perfer.reset
    $LOADED_FEATURES.delete_if { |file| file.include?("/#{bench.path}/") }
  end

  def output_path(args)
    args.map! { |arg| arg.to_s.sub('spec/fixtures/bench/', '') }
    path = CGI.escape args.join(' ')
    (output/path).add_ext('txt')
  end

  def test_output(*args)
    out, err = perfer(*args)
    err.should be_empty

    out.gsub!(RUBY_DESCRIPTION, '<ruby>')
    out.gsub!(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2} [+-]\d{4}/, '<time>')

    path = output_path(args)
    path.write(out) unless path.exist? # for first run

    out.should == path.read
  end

  it 'run iterative.rb' do
    test_output 'run', bench/'iterative.rb'
  end

  it 'report iterative.rb' do
    test_output 'report', bench/'iterative.rb'
  end

  it 'run input_size.rb' do
    test_output 'run', bench/'input_size.rb'
  end

  it 'report input_size.rb' do
    test_output 'report', bench/'input_size.rb'
  end
end
