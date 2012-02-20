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

    chunks = %w(foo barbaz)

    expected_body = ""
    chunks.each do |chunk|
      expected_body << chunk.length.to_s(16)+"\r\n"
      expected_body << "#{chunk}\r\n"
    end
    expected_body << "0\r\n\r\n"

    chunks.each do |chunk|
      s.send_chunk(chunk)
    end
    s.send_terminal_chunk

    assert_equal(expected_body,s.sent_data)
  end

end