module Mockingbird
  class Command
    
    attr_accessor :next_command, :callback
    
    def initialize(&block)
      self.callback = block      
    end
    
    def run(conn)
      callback.call(conn) if callback
      advance(conn)
    end
    
    def advance(conn)
      next_command.run(conn) if next_command
    end
  
  end
  
  class Wait < Command
    
    def initialize(time)
      @time = time
    end
    
    def run(conn)
      EM.add_timer(@time) do
        advance(conn)
      end
    end
  end
  
  class Close < Command
    
    def run(conn)
      puts "Sending terminal chunk"
      conn.send_terminal_chunk
      EM.add_timer(0.1) do
        conn.close_connection
      end
      advance(conn)
    end
    
  end
  
  class Quit < Command
    def run(conn)
      EM.add_timer(0.5) do
        puts "Exiting EM loop"
        EM.stop 
      end      
    end
  end
  
  class Pipe < Command
    
    def initialize(string_or_io,delay=nil)
      if string_or_io.kind_of?(String)
        @io = File.open(string_or_io,'r')
      else
        @io = string_or_io
      end
      @delay = delay
    end
    
    def run(conn)
      unless @io.eof?
        chunk = @io.readline.chomp
        conn.send_chunk(chunk)
        if @delay
          EM.add_timer(@delay) { run(conn) }
        else
          EM.schedule { run(conn) }
        end
      else
        # Reset for future calls
        @io.rewind
        advance(conn)
      end
    end
    
  end  
end