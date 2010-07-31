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
    
    def status(code, message="")
      current_connection.status = [code, message]
    end
    
    def headers(hash)
      current_connection.headers = hash
    end
    
    def send(data=nil,&block)
      add_command(Commands::Send.new(data,&block))
    end
    
    def wait(time=nil,&block)
      add_command(Commands::Wait.new(time,&block))
    end
    
    def disconnect!
      add_command(Commands::Disconnect.new)
    end
    
    def close
      add_command(Commands::Close.new)
    end
    
    def quit
      add_command(Commands::Quit.new)
    end
    
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