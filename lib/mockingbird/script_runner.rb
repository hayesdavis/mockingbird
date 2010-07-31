module Mockingbird
  
  class ScriptRunner
    
    attr_accessor :conn, :script
    
    def initialize(conn,script)
      self.conn = conn
      self.script = script
    end
    
    def run
      send_status
      send_headers
      send_body
    end
    
    def send_status
      code, message = (script.status_line || [200,"OK"])
      conn.send_status(code,message)  
    end
    
    def send_headers
      headers = {
        "Transfer-Encoding"=>"chunked",
        "Content-Type"=>"application/json",
        "Server"=>"Mockingbird"
      }.merge(script.header_data||{})
      headers.each do |name, value|
        conn.send_header(name, value)      
      end
    end
    
    def send_body
      conn.start_body
      script.body.run(conn)
    end
    
  end
  
end