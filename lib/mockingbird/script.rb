module Mockingbird
  class Script
    
    attr_accessor :status_line, :header_data, :body
    
    def initialize(&block)
      self.body = Commands::Command.new
      @last_command = body
      instance_eval(&block)
    end
    
    # Configuration API
    def status(code, message="")
      self.status_line = [code, message]
    end
    
    def headers(hash)
      self.header_data = hash
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
      if block_given?
        command = Commands::Command.new(&block)
      end
      @last_command.next_command = command
      @last_command = command
    end    
    
  end
end