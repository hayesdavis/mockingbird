require "#{File.dirname(__FILE__)}/test_helper"

class TestScriptConfig < Test::Unit::TestCase
  
  def test_status
    script = Mockingbird::Script.new do
      status 500, "Message"
    end
    
    conn_script = script.for_connection(1)
    assert_equal([500,"Message"],conn_script.status)
  end
  
  def test_headers
    script = Mockingbird::Script.new do
      headers 'X-1'=>1, 'X-2'=>2
    end
    
    conn_script = script.for_connection(1)
    assert_equal({'X-1'=>1,'X-2'=>2},conn_script.headers)    
  end
  
  def test_send_with_string
    script = Mockingbird::Script.new do
      send "test"
    end
    
    conn_script = script.for_connection(1)
    assert_equal(Mockingbird::Commands::Send,conn_script.body.next_command.class)
    
    send_command = conn_script.body.next_command
    assert_equal("test",send_command.send(:data))
  end
  
  def test_send_with_block
    script = Mockingbird::Script.new do
      send { "block" }
    end
    
    conn_script = script.for_connection(1)
    assert_equal(Mockingbird::Commands::Send,conn_script.body.next_command.class)
    
    send_command = conn_script.body.next_command
    assert_equal("block",send_command.send(:data))
  end
  
  def test_wait_with_time
    script = Mockingbird::Script.new do
      wait 1
    end
    
    conn_script = script.for_connection(1)
    assert_equal(Mockingbird::Commands::Wait,conn_script.body.next_command.class)
    
    command = conn_script.body.next_command
    assert_equal(1,command.send(:wait_time)) 
  end
  
  def test_wait_with_block
    script = Mockingbird::Script.new do
      wait { 0.5 }
    end
    
    conn_script = script.for_connection(1)
    assert_equal(Mockingbird::Commands::Wait,conn_script.body.next_command.class)
    
    command = conn_script.body.next_command
    assert_equal(0.5,command.send(:wait_time)) 
  end  
  
  def test_disconnect
    script = Mockingbird::Script.new do
      disconnect!
    end
    
    conn_script = script.for_connection(1)
    assert_equal(Mockingbird::Commands::Disconnect,conn_script.body.next_command.class)
  end
  
  def test_close
    script = Mockingbird::Script.new do
      close
    end
    
    conn_script = script.for_connection(1)
    assert_equal(Mockingbird::Commands::Close,conn_script.body.next_command.class)    
  end
  
  def test_quit
    script = Mockingbird::Script.new do
      quit
    end
    
    conn_script = script.for_connection(1)
    assert_equal(Mockingbird::Commands::Quit,conn_script.body.next_command.class)    
  end  
  
  def test_pipe
    filename = "file#{Time.now.to_i}.txt"
    File.open(filename,'w') {|f| f.puts '{"foo":"bar"}' }
    script = Mockingbird::Script.new do
      pipe filename, :wait=>1
    end
    
    conn_script = script.for_connection(1)
    assert_equal(Mockingbird::Commands::Pipe,conn_script.body.next_command.class)
    
    command = conn_script.body.next_command
    assert_equal(1,command.send(:delay))
    assert_equal(File,command.send(:io).class)
    assert_equal(filename,command.send(:io).path)
  ensure
    File.delete(filename)
  end

  def test_pipe_with_wait_proc
    filename = "file#{Time.now.to_i}.txt"
    File.open(filename,'w') {|f| f.puts '{"foo":"bar"}' }
    script = Mockingbird::Script.new do
      pipe filename, :wait=>Proc.new{ 0.5 }
    end
    
    conn_script = script.for_connection(1)
    assert_equal(Mockingbird::Commands::Pipe,conn_script.body.next_command.class)
    
    command = conn_script.body.next_command
    assert_equal(0.5,command.send(:delay))
  ensure
    File.delete(filename)    
  end
  
  def test_command_chain
    script = Mockingbird::Script.new do
      send "1"
      wait 1
      close
    end
    
    conn_script = script.for_connection(1)
    cmd = conn_script.body
    assert_equal(Mockingbird::Commands::Command,cmd.class,"Empty command to start")
    cmd = cmd.next_command
    assert_equal(Mockingbird::Commands::Send,cmd.class)
    cmd = cmd.next_command
    assert_equal(Mockingbird::Commands::Wait,cmd.class)
    cmd = cmd.next_command
    assert_equal(Mockingbird::Commands::Close,cmd.class)
    cmd = cmd.next_command
    assert_nil(cmd,"Last command has no next command")
  end
  
  def test_on_connection
    script = Mockingbird::Script.new do
      on_connection(1) do
        send "1"
      end
      on_connection(2..3) do
        send "2-3"
      end
      on_connection(Proc.new{|conn| conn == 4}) do
        send "4"
      end
      on_connection("*") do
        send "*"
      end
    end
    
    conn1 = script.for_connection(1)
    cmd = conn1.body.next_command
    assert_equal(Mockingbird::Commands::Send,cmd.class)
    assert_equal("1",cmd.send(:data))
    
    (2..3).each do |id|
      conn = script.for_connection(id)
      cmd = conn.body.next_command
      assert_equal(Mockingbird::Commands::Send,cmd.class)
      assert_equal("2-3",cmd.send(:data))      
    end
    
    conn4 = script.for_connection(4)
    cmd = conn4.body.next_command
    assert_equal(Mockingbird::Commands::Send,cmd.class)
    assert_equal("4",cmd.send(:data))
    
    (5..10).each do |id|
      conn = script.for_connection(id)
      cmd = conn.body.next_command
      assert_equal(Mockingbird::Commands::Send,cmd.class)
      assert_equal("*",cmd.send(:data))
    end
    
  end
  
end