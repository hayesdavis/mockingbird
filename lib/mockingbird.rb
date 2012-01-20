# External dependencies
require 'rubygems'
require 'eventmachine'

# Mockingbird code
require 'mockingbird/version'
require 'mockingbird/commands'
require 'mockingbird/connection_script'
require 'mockingbird/script'
require 'mockingbird/script_runner'
require 'mockingbird/server'

module Mockingbird
  
  class << self
    
    # Convenience method for starting a mockingbird server during a test. 
    # This will be most users' primary interface to mockingbird. The mockingbird 
    # server will be forked as a separate process. Ensure that your test code 
    # always calls teardown at some point after setup, or the separate process 
    # will not be terminated.
    # 
    # Options are
    #   :host - The host to listen on. 0.0.0.0 by default
    #   :port - The port to listen on. 4879 by default
    #   :quiet - Silence debug-output. Default is to be verbose
    #
    # The block is a Mockingbird configuration (see README).
    def setup(opts={},&block)
      Server.configure(&block)
      @pid = fork do
        opts = {:host=>'0.0.0.0',:port=>4879}.merge(opts)
        $0 = "mockingbird:#{opts[:host]}:#{opts[:port]}"
        Server.start!(opts)
      end
      Process.detach(@pid)
      puts "Waiting for Mockingbird to start..." unless opts[:quiet]
      sleep(1) # Necessary to make sure the forked proc is up and running
      @pid
    end
    
    # Terminates the mockingbird server created by a call to setup. Make sure 
    # to always pair this call with setup to ensure that mockingbird server 
    # processes don't linger. If you're using test/unit, the recommended 
    # pattern is to actually call setup and teardown here during the setup and 
    # teardown phase of your unit tests. Otherwise, use the following pattern:
    # 
    #   def test_something
    #     Mockingbird.setup(:port=>NNNN) do
    #       # config here
    #     end
    #     # do tests
    #   ensure
    #     Mockingbird.teardown
    #   end
    def teardown
      Process.kill('KILL',@pid)
    end    
    
  end
  
end