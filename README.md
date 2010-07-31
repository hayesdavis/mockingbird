Mockingbird
===========
Mockingbird emulates the Twitter Streaming API using a simple script-like 
configuration that makes it easy to test code that connects to the Streaming 
API. Mockingbird can be used to simulate bad data, unexpected status codes, 
hard disconnects, etc.

Mockingbird uses eventmachine to run as an actual streaming http server so
it's a drop-in replacement for code that reads from the streaming api. 
Simply change the host and port your code is connecting to from Twitter to 
a mockingbird instance.

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
* Then send each line from some/file.txt to the clien, waiting 1 second in 
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
          send send '{"foo":"bar"}'
        end
        close
      end
    end
    
Again, in plain english:

* On the first connection, we do a hard disconnect (just drop the connection)
* On connections 2-5, wait a half second, then close the connection nicely
* On all subsequent connections ("*"), send down 100 foo bars and close

See the docs on Mockingbird::Script for all the available configuration options.

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
