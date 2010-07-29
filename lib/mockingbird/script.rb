module Mockingbird
  class Script
    
    def initialize(&block)
      @command_root = Command.new
      @last_command = @command_root
      configure(&block) if block_given?
    end
    
    def configure(&block)
      instance_eval(&block)
    end
    
    def add_command(command=nil,&block)
      if block_given?
        command = Command.new(&block)
      end
      @last_command.next_command = command
      @last_command = command
    end
    
    # Configuration API
    def send(data)
      add_command do |conn|
        conn.send_chunk(data)
      end
    end
    
    def wait(time)
      add_command(Wait.new(time))
    end
    
    def disconnect!
      add_command do |conn|
        puts "disconnecting"
        conn.close_connection
      end
    end
    
    def close
      add_command(Close.new)
    end
    
    def quit
      add_command(Quit.new)
    end
    
    def pipe(string_or_io,opts={})
      add_command(Pipe.new(string_or_io,opts[:wait]))
    end
    
    def run(conn)
      @command_root.run(conn)
    end
    
  end
end