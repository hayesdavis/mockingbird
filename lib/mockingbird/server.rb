module Mockingbird

  # A very simple eventmachine-based streaming server. Before you use a server
  # it must be configured with configuration block:
  #
  #   Mockingbird::Server.configure do
  #     # config goes here, see README for scripting
  #   end
  #
  # Once configured, a server may be started using
  # 
  #   start!(:host=>'0.0.0.0',:port=>NNN)
  #
  # If you're using Mockingbird directly from test (test/unit, etc), it's 
  # recommended that you use the simpler convenience interface defined on 
  # the Mockingbird module.
  module Server

    class << self

      def start!(opts={})
        opts = {:host=>'0.0.0.0',:port=>8080}.merge(opts)
        host = opts[:host]
        port = opts[:port]
        EventMachine::run do
          puts "Mockingbird is mocking you on #{host}:#{port} (pid=#{$$})" unless opts[:quiet]
          EventMachine::start_server host, port, self
        end
      end

      def configure(&block)
        @script = Script.new(&block)
      end

      def script
        @script
      end

      def new_connection_id
        @connection_id ||= 0
        @connection_id += 1
      end

    end

    def receive_data(data)
      conn_id = new_connection_id
      runner = ScriptRunner.new(self,script.for_connection(conn_id))
      runner.run
    end

    def new_connection_id
      Mockingbird::Server.new_connection_id
    end

    def script
      Mockingbird::Server.script
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
      len = chunk_length(chunk)
      send_data "#{len.to_s(16)}\r\n"
      send_data "#{chunk}\r\n"
    end

    def send_terminal_chunk
      send_data "0\r\n"
    end

    private
      def chunk_length(chunk)
        # Be friendly to 1.8 and 1.9. In 1.9, length is the char length, not
        # the byte length
        if chunk.respond_to?(:bytesize)
          chunk.bytesize
        else
          chunk.length
        end
      end
  end
end