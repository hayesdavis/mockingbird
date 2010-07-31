require 'rubygems'
require 'eventmachine'
require File.dirname(__FILE__)+'/commands'
require File.dirname(__FILE__)+'/script'

module Mockingbird

  module Server
  
    class << self
      def start!(opts={})
        opts = {:host=>'0.0.0.0',:port=>8080}.merge(opts)
        host = opts[:host]
        port = opts[:port]
        run = Proc.new do
          $0 = "mockingbird:#{host}:#{port}"
          EventMachine::run do
            puts "Mockingbird is mocking you on #{host}:#{port}"
            EventMachine::start_server host, port, self
          end
        end
        if opts[:fork]
          pid = fork(&run)
          Process.detach(pid)
        else
          run.call
        end
      end
      
      def configure(&block)
        @script = Script.new(&block)
      end
      
      def script
        @script
      end
      
    end
    
    def receive_data(data)
      runner = ScriptRunner.new(self,Mockingbird::Server.script)
      runner.run
    end
    
    def send_status(code=200,text="OK")
      send_data "HTTP/1.1 #{code} #{text}\r\n"
    end
    
    def send_header(name,value)
      send_data "#{name}: #{value}\r\n"
    end
    
    def start_body
      send_data "\r\n"
    end
    
    def send_chunk(chunk)
      puts "Sending: #{chunk}"
      res = %Q(#{chunk}\r\n)
      send_data "#{res.length.to_s(16)}\r\n"
      send_data "#{res}\r\n"
    end
    
    def send_terminal_chunk
      send_data "0\r\n\r\n"
    end
    
  end
end