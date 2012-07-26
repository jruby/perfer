require 'spec_helper'
require 'cgi'

describe 'perfer integration tests' do
  let(:bench) { Path('spec/fixtures/bench') }
  let(:output) { Path('spec/integration/output') }

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
    out.gsub!(/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}/, '<time>')
    out.gsub!(Dir.getwd, '<cwd>')

    path = output_path(args)
    path.write(out) unless path.exist? # for first run

    out.should == path.read
  end

  it 'help' do
    test_output 'help'
  end

  it 'run iterative.rb' do
    Perfer.stub(:measure) { { :real => 0.1, :stime => 0.05 } }
    test_output 'run', bench/'iterative.rb'
  end

  it 'report iterative.rb' do
    test_output 'report', bench/'iterative.rb'
  end

  it 'report --measurements iterative.rb' do
    test_output 'report', '--measurements', bench/'iterative.rb'
  end

  it 'run input_size.rb' do
    times = [
      # first job
      0.004, 0.008, 0.016, # warm-up
      0.004, 0.003, # for start
      0.008, 0.008, # start*2
      0.016, 0.015, # start*4
      # second job
      0.1,      # warm-up
      0.1, 0.1, # for start
      nil # end
    ]
    Perfer.stub(:measure).and_return(*times.map { |t| { :real => t, :utime => 0.002 } })
    test_output 'run', bench/'input_size.rb'
  end

  it 'report input_size.rb' do
    test_output 'report', bench/'input_size.rb'
  end

  it 'report --measurements input_size.rb' do
    test_output 'report', '--measurements', bench/'input_size.rb'
  end

  it 'results path iterative.rb' do
    test_output 'results', 'path', bench/'iterative.rb'
  end

  it 'results rm iterative.rb' do
    test_output 'results', 'rm', bench/'iterative.rb'
  end
end
