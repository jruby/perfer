require 'spec_helper'

describe "Perfer metadata" do
  it 'gets recorded' do
    session = Perfer.session 'test' do |s|
      s.metadata do
        description "Sorting an Array"
        tags Array, :sort
      end
      s.bench('iter1') {}
    end
    metadata = session.jobs.first.metadata
    metadata[:description].should == "Sorting an Array"
    metadata[:tags].should == %w[Array sort]
  end

  it 'handles start and generator as well' do
    start = 1
    generator = lambda { |n| 2**n }
    session = Perfer.session do |s|
      s.metadata do
        description "Sorting an Array"
        tags Array, :sort
        start start
        generator(&generator)
      end
      s.bench('iter1') {}
    end
    job = session.jobs.first
    metadata = job.metadata
    metadata.should_not have_key :start
    metadata.should_not have_key :generator
    job.instance_variable_get(:@start).should == start
    job.instance_variable_get(:@generator).should == generator
  end
end
