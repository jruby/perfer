require 'spec_helper'

describe "Perfer::Platform.command_line" do
  it 'gives back the command line that launched this process' do
    Perfer::Platform.command_line.should match(/(?:j?ruby|rbx) /)
  end
end
