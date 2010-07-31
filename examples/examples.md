How to run examples
===================
It's easiest to do this if you have curl. From the root directory of this 
project run the following

    $ ruby examples/EXAMPLE_FILE.rb
    Waiting for Mockingbird to start...
    Mockingbird is mocking you on 0.0.0.0:8080 (pid=50990)    
    $ curl -v http://localhost:8080 
   
Depending on the example file and your version of curl, you'll see something 
similar to this:
    * About to connect() to 0.0.0.0 port 8080 (#0)
    *   Trying 0.0.0.0... connected
    * Connected to 0.0.0.0 (0.0.0.0) port 8080 (#0)
    > GET / HTTP/1.1
    > User-Agent: curl/7.19.6 (i386-apple-darwin9.7.0) libcurl/7.19.6 zlib/1.2.3
    > Host: 0.0.0.0:8080
    > Accept: */*
    > 
    < HTTP/1.1 200 OK
    < Transfer-Encoding: chunked
    < Content-Type: application/json
    < Server: Mockingbird
    < 
    * Connection #0 to host 0.0.0.0 left intact
    * Closing connection #0

When you're done you need to kill the mockingbird server which is running in 
its own process. You can grep it like below or use the pid printed when you 
ran the example file.

    $ ps | grep mockingbird
    50990 ttys006    0:00.33 mockingbird:0.0.0.0:8080
    $ kill -9 50990