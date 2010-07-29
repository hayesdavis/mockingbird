require 'rubygems'
require 'eventmachine'
require File.dirname(__FILE__)+'/commands'
require File.dirname(__FILE__)+'/script'

module Mockingbird

  module Server
  
    class << self
      def start!(opts={})
        opts = {:host=>'0.0.0.0',:port=>8080}.merge(opts)
        run = Proc.new do
          $0 = "mockingbird:#{opts[:host]}:#{opts[:port]}"
          EventMachine::run do
            puts "Started mockingbird"
            EventMachine::start_server opts[:host], opts[:port], self
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
      send_data "HTTP/1.1 200 OK\r\n"
      send_data "Content-Type: application/json\r\n"
      send_data "Transfer-Encoding: chunked\r\n"
      send_data "\r\n"
      
      Mockingbird::Server.script.run(self)
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