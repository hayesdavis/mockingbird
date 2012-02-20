require "#{File.dirname(__FILE__)}/test_helper"

class ServerTest < Test::Unit::TestCase

  class MockServer
    include Mockingbird::Server

    def sent_data
      @sent_data ||= ""
    end

    def send_data(data)
      self.sent_data << data
    end
  end

  def test_send_chunk_encodes_data_correctly
    s = MockServer.new
    s.send_chunk("foobar")
    s.send_terminal_chunk

    chunk_len = "foobar".length.to_s(16)

    assert_equal("#{chunk_len}\r\nfoobar\r\n0\r\n",s.sent_data)
  end

end