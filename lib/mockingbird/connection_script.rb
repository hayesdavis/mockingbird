module Mockingbird
  
  class ConnectionScript
    
    attr_accessor :status, :headers, :body

    def initialize
      self.body = Commands::Command.new
      @last_command = body
    end
    
    def add_command(command=nil)
      @last_command.next_command = command
      @last_command = command
    end
    
  end
  
end