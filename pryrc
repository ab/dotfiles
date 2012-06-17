# ORI help module
begin
  require 'rubygems'
  require 'ori'
rescue LoadError => err
  puts "Error loading ORI: #{err}"
end

# alias ll => exec ls -l --color
def ll
  _pry_
end

# local_methods shows methods that are only available for a given object
class Object
  def local_methods
    self.methods.sort - self.class.superclass.methods
  end
end

Pry::Commands.command 'll', 'Execute ls -l in a shell.' do
  run ".ls -l --color #{arg_string}"
end

# quick sample data
Myhash = {:foo=>'red', :bar=>'green', :baz=>'blue'} if not defined? Myhash
Myarray = ['foo', 'bar', 'baz'] if not defined? Myarray

# vim: ft=ruby