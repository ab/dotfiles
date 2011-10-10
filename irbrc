# enable tab-completion
require 'irb/completion'

# readline + history
require 'irb/ext/save-history'
IRB.conf[:USE_READLINE] = true
IRB.conf[:SAVE_HISTORY] = 1000
#IRB.conf[:HISTORY_PATH]

# auto-indentation
IRB.conf[:AUTO_INDENT] = true

# local_methods shows methods that are only available for a given object
class Object
  def local_methods
    self.methods.sort - self.class.superclass.methods
  end
end

# colorize output
begin
  require 'wirble'
  Wirble.init
  Wirble.colorize
rescue LoadError => err
  puts "Error loading Wirble: #{err}"
end

def less
  spool_output('less')
end

def spool_output(spool_cmd)
  require 'stringio'
  $stdout, sout = StringIO.new, $stdout
  yield
  $stdout, str_io = sout, $stdout
   IO.popen(spool_cmd, 'w') do |f|
     f.write str_io.string
     f.flush
     f.close_write
   end
end

# ORI help module
begin
  require 'rubygems'
  require 'ori'
rescue LoadError => err
  puts "Error loading ORI: #{err}"
end

