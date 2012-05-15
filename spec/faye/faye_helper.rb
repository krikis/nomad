require 'spec_helper'

faye_dir = File.join(File.expand_path(File.dirname(__FILE__)), '..', '..', 'faye')
$LOAD_PATH.unshift faye_dir unless $LOAD_PATH.include? faye_dir
