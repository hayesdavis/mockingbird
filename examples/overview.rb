#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')
require 'mockingbird'

Mockingbird.setup(:port=>8080) do
  send %Q({"foo":"bar"}\r\n)
  wait 0.5
  5.times do |n|
    send %Q({"foo":"bar#{n}"}\r\n)
  end
  pipe "#{File.dirname(__FILE__)}/overview_output.txt", :wait=>1
  close
end