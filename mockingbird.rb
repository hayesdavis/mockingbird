$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/lib')

require 'mockingbird/commands'
require 'mockingbird/connection_script'
require 'mockingbird/script'
require 'mockingbird/script_runner'
require 'mockingbird/server'

module Mockingbird
  
  class << self
    
    def setup(opts={},&block)
      Server.configure(&block)
      @pid = fork do
        opts = {:host=>'0.0.0.0',:port=>4879}.merge(opts)
        $0 = "mockingbird:#{opts[:host]}:#{opts[:port]}"
        Server.start!(opts)
      end
      Process.detach(@pid)
      puts "Waiting for Mockingbird to start..."
      sleep(1)
    end
    
    def teardown
      Process.kill('KILL',@pid)
    end    
    
  end
  
end