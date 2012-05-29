require 'spec_helper'
# add faye source files to loadpath
faye_dir = File.join(File.expand_path(File.dirname(__FILE__)), '..', '..', 'faye')
$LOAD_PATH.unshift faye_dir unless $LOAD_PATH.include? faye_dir
# write logging to faye server log
@logfile = File.join(faye_dir, 'log', 'faye.log')
Faye.logger = lambda {|m| File.open(@logfile, 'a'){|f| f.puts m}}