require 'spec_helper'

describe Perfer::Statistics do
  data = [1.082077, 1.079686, 1.079917, 1.079567, 1.078591,
          1.078359, 1.077917, 1.079169, 1.075793, 1.065655]
  stats = Perfer::Statistics.new(data)
  subject { stats }

  its(:size)                      { should == 10 }
  its(:mean)                      { should be_within(1e-6).of 1.077673 }
  its(:median)                    { should be_within(1e-6).of 1.07888 }
  its(:variance)                  { should be_within(1e-11).of 2.040531e-05 }
  its(:standard_deviation)        { should be_within(1e-9).of 0.004517223 }
  its(:coefficient_of_variation)  { should be_within(1e-9).of 0.004191645 }
  its(:standard_error)            { should be_within(1e-9).of 0.001428471 }
  its(:mean_absolute_deviation)   { should be_within(1e-8).of 0.00277964 }
  its(:median_absolute_deviation) { should be_within(1e-7).of 0.0008845 }
  its(:margin_of_error)           { should be_within(1e-9).of 0.003231202 }
  its(:maximum_absolute_deviation){ should be_within(1e-7).of 0.0120181 }

  it "confidence interval test" do
    d = [19.3, 20.1, 20.4, 19.6, 19.1, 20.2, 19.8, 20.3, 20.1, 19.6]
    s = Perfer::Statistics.new(d)
    (s.mean - s.margin_of_error).should be_within(1e-2).of 19.53
    (s.mean + s.margin_of_error).should be_within(1e-2).of 20.17
  end
end
