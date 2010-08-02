Mockingbird
===========
Mockingbird makes it easy to test code that relies on the 
[Twitter Streaming API](http://dev.twitter.com/pages/streaming_api). It's a 
server with a simple script-like configuration DSL that makes it easy to 
describe the behaviors you want. Mockingbird can be used to simulate bad data, 
unexpected status codes, hard disconnects, etc. It's currently used heavily to 
test the  [flamingo](http://github.com/hayesdavis/flamingo) Streaming API 
service.

Mockingbird uses [eventmachine](http://github.com/eventmachine/eventmachine/) 
to run as an actual streaming HTTP server so it's a drop-in replacement for 
the server at stream.twitter.com. To test code that uses the Streaming API, 
connect to a running mockingbird server instead of stream.twitter.com. Most 
Twitter Streaming API clients, such as 
[twitter-stream](http://github.com/voloko/twitter-stream), allow you to easily 
change these host and port settings.

Since mockingbird is designed for testing, it includes a simple 
Mockingbird#setup and Mockingbird#teardown interface that makes it easy to 
configure and spawn a server for testing purposes during unit tests.

Configuration Quickstart
------------------------
Mockingbird uses a simple script-like configuration API for telling a 
mockingbird server what you want it to do. Here's a simple example:

    Mockingbird.setup(:port=>8080) do
      send '{"foo":"bar"}'
      wait 1
      5.times do
        send '{"foo2":"bar2"}'
      end
      pipe "some/file.txt", :wait=>1
      close
    end
    
Here's what this does in plain english:

* Tells the server to listen on port 8080 and do the stuff in the block on 
  each connection.
* On a connection, send '{"foo":"bar"}' down to the client
* Wait 1 second
* Then send '{"foo2":"bar2"}' down to the client 5 times
* Then send each line from some/file.txt to the client, waiting 1 second in 
  between sends
* Close the connection
  
Mockingbird assigns each conection an incrementing id. This means you can 
specify behavior over multiple connections with different connections doing 
different things. This is handy for testing reconnection code:

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
    
Again, in plain english:

* On the first connection, we do a hard disconnect (just drop the connection)
* On connections 2-5, wait a half second, then close the connection nicely
* On all subsequent connections ("*"), send down 100 foo bars and close

See the docs on Mockingbird::Script for all the available configuration options.
Also, see the examples directory for more usage.

Using in Tests
--------------
The basic pattern for using Mockingbird in your unit tests is to simply call 
Mockingbird#setup and Mockingbird#teardown at appropriate times. This will 
setup a mockingbird server in a separate process and then kill it when you're 
done. Make sure to *always* call Mockingbird#teardown. This is easy in test/unit 
if you're actually calling these methods in setup and teardown. If you need to 
setup and teardown a server in a test method, do the following:

    def test_something
      Mockingbird.setup(:port=>NNNN) do
         # config here
      end
      # do tests
    ensure
      Mockingbird.teardown
    end  

Limitations
-----------
* SSL is not supported.
* Since connection ids are incrementing with each connection you won't be able 
  able to easily target specific connections if you have multiple clients 
  connecting at once to the mockingbird server. It's generally recommended that 
  you have a single client connecting to mockingbird serially during a single 
  test run. Doing otherwise would probably be confusing anyway.
* The server does not even pay attention to your actual request, it will just 
  always respond with the defined configuration script regardless of what you 
  send on connection.