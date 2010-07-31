module Mockingbird
  class Script
    
    def initialize(&block)
      @connections = []
      @default_connection = ConnectionScript.new
      instance_eval(&block)
    end
    
    def for_connection(id)
      match = @connections.find do |selector, *|
        case selector
          when Range    then selector.include?(id)
          when Numeric  then selector == id
          when Proc     then selector.call(id)
        end
      end
      match ? match.last : @default_connection
    end
    
    # Configuration API
    
    # Specifies behavior to run for specific connections based on the id number 
    # assigned to that connection. Connection ids are 1-based.
    #
    # The selector can be any of the following:
    #   Number - Run the code on that connection id
    #   Range - Run the code for a connection id in that range
    #   Proc - Call the proc with the id and run if it matches
    #   '*' - Run this code for any connection that doesn't match others
    def on_connection(selector=nil,&block)
      if selector.nil? || selector == '*'
        instance_eval(&block)
      else
        @current_connection = ConnectionScript.new
        instance_eval(&block)
        @connections << [selector,@current_connection]
        @current_connection = nil
      end
    end
    
    # Send an HTTP status code to the client. e.g. a 403 or 404
    def status(code, message="")
      current_connection.status = [code, message]
    end
    
    # Send the hash of headers to the client.
    def headers(hash)
      current_connection.headers = hash
    end
    
    # Send some text down to the client. If a block is specified that block 
    # will be called on each connection to determine what text to send. This 
    # permits sending randomized data.
    def send(data=nil,&block)
      add_command(Commands::Send.new(data,&block))
    end
    
    # Wait a certain number of seconds. Fractional seconds are allowed. If a 
    # block is specified, it will be called on each attempt. This permits things 
    # like adding randomized waits.
    def wait(time=nil,&block)
      add_command(Commands::Wait.new(time,&block))
    end
    
    # Perform a hard disconnect by just closing the connection
    def disconnect!
      add_command(Commands::Disconnect.new)
    end
    
    # Do a clean close
    def close
      add_command(Commands::Close.new)
    end
    
    # Exit the server entirely
    def quit
      add_command(Commands::Quit.new)
    end
    
    # Send the lines from string_or_io down one at a time. The :wait option 
    # can be used to specify a configurable delay between lines.
    def pipe(string_or_io,opts={})
      add_command(Commands::Pipe.new(string_or_io,opts[:wait]))
    end
    
    # Not really part of the public API but users could use this to 
    # implement their own fancy command
    def add_command(command=nil,&block)
      command = Commands::Command.new(&block) if block_given?
      current_connection.add_command(command)
    end
    
    private
      def current_connection
        @current_connection || @default_connection
      end
    
  end
end