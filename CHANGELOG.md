0.2.0
=====
* Fix chunked encoding bug. Scripts that used to rely on "\r\n" being 
  automatically appended to each send call need to be updated to manually add 
  "\r\n" (or whatever line ending) as appropriate.

0.1.1
=====
* Add :quiet flag to silence puts during tests (thanks @rud)

0.1.0
=====
* Initial release