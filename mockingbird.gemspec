$LOAD_PATH.unshift 'lib'
require 'mockingbird/version'

Gem::Specification.new do |s|
  s.name              = "mockingbird"
  s.version           = Mockingbird::Version
  s.date              = Time.now.strftime('%Y-%m-%d')
  s.summary           = "Mockingbird is a mock server for testing with the Twitter Streaming API."
  s.homepage          = "http://github.com/hayesdavis/mockingbird"
  s.email             = "hayes@appozite.com"
  s.authors           = [ "Hayes Davis"]
  
  s.files             = %w( README.md )
  s.files            += Dir.glob("lib/**/*")
  s.files            += Dir.glob("examples/**/*")

  s.extra_rdoc_files  = [ "LICENSE", "README.md", "CHANGELOG.md" ]

  s.add_dependency "eventmachine",  ">= 0.12.0"

  s.description = <<-description
    Mockingbird emulates the Twitter Streaming API using a simple script-like 
    configuration that makes it easy to test code that connects to the Streaming 
    API. Mockingbird can be used to simulate bad data, unexpected status codes, 
    hard disconnects, etc.
    
    Mockingbird uses eventmachine to run as an actual streaming http server so
    it's a drop-in replacement for code that reads from the streaming api. 
    Simply change the host and port your code is connecting to from Twitter to 
    a running Mockingbird.
  description
end
