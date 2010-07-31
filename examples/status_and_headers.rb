#!/usr/bin/env ruby

$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/../lib')
require 'mockingbird'

Mockingbird.setup(:port=>8080) do
  status 404, "Not Found"
  headers "X-Hi-There"=>"Howdy"
  close
end