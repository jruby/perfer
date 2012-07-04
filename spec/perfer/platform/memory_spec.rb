require 'spec_helper'

describe "Perfer::Platform.maximum_memory_used" do
  def memory_used
    Perfer::Platform.maximum_memory_used / (1024*1024) # in MB
  end

  it 'reports the maximum memory used until now' do
    (1..150).should include memory_used

    # allocate 100MB
    a = Array.new(100*1024*1024/0.size, 0)

    (101..250).should include memory_used

    a.size
  end
end
