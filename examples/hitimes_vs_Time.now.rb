require 'hitimes'

module HiTimesVsTimeNow
  extend self
  def hitimes(&block)
    Hitimes::Interval.measure(&block)
  end

  def time_now
    t=Time.now
    yield
    Time.now-t
  end

  def time_now_block(&block)
    t=Time.now
    block.call
    Time.now-t
  end
end

Perfer.session 'hitimes vs Time.now' do |s|
  s.iterate 'hitimes' do
    HiTimesVsTimeNow.hitimes { 1 }
  end

  s.iterate 'Time.now' do
    HiTimesVsTimeNow.time_now { 1 }
  end

  s.iterate 'Time.now &block' do
    HiTimesVsTimeNow.time_now_block { 1 }
  end
end
