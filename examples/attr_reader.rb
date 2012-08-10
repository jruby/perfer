class Foo
  attr_accessor :a

  def a2
    @a
  end

  def initialize
    @a = 1
  end
end

foo = Foo.new

Perfer.session "attr_reader" do |s|
  s.iterate "control: attr_reader",        "a",  :self => foo
  s.iterate "core: ruby-defined attr get", "a2", :self => foo
end
