require 'spec_helper'

describe "Perfer::Platform.command_line" do
  it 'gives back the command line that launched this process' do
    Perfer::Platform.command_line.should match /ruby|jruby|rbx/
  end
end
