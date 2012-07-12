require 'spec_helper'

describe Perfer::Session do
  it 'creates a benchmark session' do
    session = Perfer.session 'test' do |s|
      s.iterate('iter1') {}
      s.iterate('iter2') {}
    end
    session.jobs.size.should == 2
  end

  it 'does not allow mixing job type' do
    expect do
      Perfer.session 'test' do |s|
        s.iterate('iter') {}
        s.bench('bench') {}
      end
    end.to raise_error(/Cannot mix iterations and input size benchmarks/)
  end

  it 'does not allow two jobs with the same name' do
    expect do
      Perfer.session 'test' do |s|
        s.iterate('iter') {}
        s.iterate('iter') {}
      end
    end.to raise_error(/jobs with the same title are not allowed/)
  end
end
