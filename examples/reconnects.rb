#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')
require 'mockingbird'

# Note: you'll need to run curl several times to see the full effect of this one

Mockingbird.setup(:port=>8080) do
  on_connection(1) do
    disconnect!
  end
  
  on_connection(2..5) do
    wait(0.5)
    close
  end
  
  on_connection('*') do
    100.times do
      send '{"foo":"bar"}'
    end
    close
  end
end