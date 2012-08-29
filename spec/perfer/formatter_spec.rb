require 'spec_helper'

describe Perfer::Formatter do
  it 'short_ruby_description' do
    {
      'ruby 1.8.7 (2011-02-18 patchlevel 334) [x86_64-linux]' => 'mri 1.8.7p334',
      'ruby 1.8.7 (2011-06-30 patchlevel 352) [x86_64-linux]' => 'mri 1.8.7p352',
      'ruby 1.8.7 (2011-02-18 patchlevel 334) [x86_64-linux], MBARI 0x6770, Ruby Enterprise Edition 2011.03' => 'ree 2011.03 (1.8.7p334)',
      'ruby 1.9.2p290 (2011-07-09 revision 32553) [x86_64-linux]' => 'mri 1.9.2p290 r32553',
      'ruby 1.9.3dev (2011-07-31 revision 32789) [x86_64-linux]' => 'mri 1.9.3dev r32789',
      'ruby 1.9.3p125 (2012-02-16 revision 34643) [x86_64-darwin10.8.0]' => 'mri 1.9.3p125 r34643',
      'ruby 1.9.4dev (2011-08-24 trunk 33047) [x86_64-linux]' => 'mri 1.9.4dev r33047',
      'ruby 2.0.0dev (2012-08-25 trunk 36824) [x86_64-darwin10.8.0]' => 'mri 2.0.0dev r36824',
      'rubinius 1.2.4 (1.8.7 release 2011-07-05 JI) [x86_64-apple-darwin10.8.0]' => 'rbx 1.2.4 2011-07-05 (1.8.7)',
      'rubinius 1.2.5dev (1.8.7 489d5384 yyyy-mm-dd JI) [x86_64-unknown-linux-gnu]' => 'rbx 1.2.5dev 489d5384 (1.8.7)',
      'rubinius 2.0.0dev (1.8.7 d705d318 yyyy-mm-dd JI) [x86_64-unknown-linux-gnu]' => 'rbx 2.0.0dev d705d318 (1.8.7)',
      'rubinius 2.0.0dev (1.9.3 af9f288d yyyy-mm-dd JI) [x86_64-apple-darwin10.8.0]' => 'rbx 2.0.0dev af9f288d (1.9.3)',
      'jruby 1.6.3 (ruby-1.8.7-p330) (2011-07-07 965162f) (OpenJDK 64-Bit Server VM 1.6.0_22) [linux-amd64-java]' => 'jruby 1.6.3 965162f (1.8.7p330)',
      'jruby 1.7.0.dev (ruby-1.8.7-p330) (2011-08-24 7b9f999) (OpenJDK 64-Bit Server VM 1.6.0_22) [linux-amd64-java]' => 'jruby 1.7.0.dev 7b9f999 (1.8.7p330)',
      'jruby 1.7.0.preview2 (1.9.3p203) 2012-08-07 fffffff on Java HotSpot(TM) 64-Bit Server VM 1.6.0_33-b03-424-10M3720 [darwin-x86_64]' => 'jruby 1.7.0.preview2 2012-08-07 (1.9.3p203)',
      'jruby 1.7.0.preview2 (1.9.3p203) 2012-08-07 ea329bd on Java HotSpot(TM) 64-Bit Server VM 1.6.0_33-b03-424-10M3720 [darwin-x86_64]' => 'jruby 1.7.0.preview2 ea329bd (1.9.3p203)',
      'MacRuby 0.9 (ruby 1.9.2) [universal-darwin10.0, x86_64]' => 'macruby 0.9 (1.9.2)',
    }.each_pair { |description, short|
      Perfer::Formatter.short_ruby_description(description).should == short
    }
  end
end
