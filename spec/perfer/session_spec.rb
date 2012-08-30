require 'spec_helper'

describe Perfer::Session do
  it 'creates a benchmark session' do
    session = Perfer.session 'test' do |s|
      s.iterate('iter1') {}
      s.iterate('iter2') {}
    end
    session.jobs.size.should == 2
  end

  it 'has a shortcut Perfer.iterate {}' do
    session = Perfer.iterate {}
    session.name.should == "session_spec"
    session.jobs.size.should == 1
    session.jobs.first.title.should == "session_spec"
  end

  it 'has a shortcut Perfer.iterate(title) {}' do
    session = Perfer.iterate("job title") {}
    session.name.should == "session_spec"
    session.jobs.size.should == 1
    session.jobs.first.title.should == "job title"
  end

  it 'does not allow mixing job type' do
    expect {
      Perfer.session 'test' do |s|
        s.iterate('iter') {}
        s.bench('bench') {}
      end
    }.to raise_perfer_error :MIX_BENCH_TYPES
  end

  it 'does not allow two jobs with the same name' do
    expect {
      Perfer.session 'test' do |s|
        s.iterate('iter') {}
        s.iterate('iter') {}
      end
    }.to raise_perfer_error :SAME_JOB_TITLES
  end
end
