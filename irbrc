# enable tab-completion
require 'irb/completion'

# pp is nice, and so is set
require 'pp'
require 'set'

# usually want yaml as well
require 'yaml'

# readline + history
require 'irb/ext/save-history'
IRB.conf[:USE_READLINE] = true
IRB.conf[:SAVE_HISTORY] = 10000
#IRB.conf[:HISTORY_PATH]

# auto-indentation
IRB.conf[:AUTO_INDENT] = true

# local_methods shows methods that are only available for a given object
class Object
  def local_methods
    self.methods.sort - self.class.superclass.methods
  end
end

# colorize output, but don't mess with normal irb history
begin
  require 'rubygems'
  require 'wirble'
  Wirble.init(:skip_history => true)
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

def timeit
  start = Time.now.utc
  ret = yield
  STDERR.puts Time.now.utc - start
  ret
end

# quick sample data
Myhash = {:foo=>'red', :bar=>'green', :baz=>'blue'} if not defined? Myhash
Myarray = ['foo', 'bar', 'baz'] if not defined? Myarray

# metaclass tomfoolery
def metaclass_tomfoolery_begin
  Object.class_eval do
    def metaclass
      class << self
        self
      end
    end

    def meta_eval &blk
      metaclass.instance_eval &blk
    end

    # add methods to a metaclass
    def meta_def name, &blk
      meta_eval { define_method name, &blk }
    end

    # define an instance method within a class
    def class_def name, &blk
      class_eval { define_method name, &blk }
    end
  end
end
