require 'spec_helper'

describe "Perfer::Platform.{maximum_,}memory_used" do
  def memory_used
    Perfer::Platform.memory_used / (1024*1024) # in MB
  end
  def max_memory_used
    Perfer::Platform.maximum_memory_used / (1024*1024) # in MB
  end

  it 'reports the maximum memory used until now and the current memory usage' do
    (1..200).should include memory_used
    (1..200).should include max_memory_used
  end
end
