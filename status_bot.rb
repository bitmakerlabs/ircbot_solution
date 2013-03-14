# This is required for connecting to IRC
require "socket"
# These are required for querying Github's API
require 'net/http'
require 'curb'
require 'json'

class StatusBot

  def initialize
    nick = "BitMakers_StatusBot"
    channel = "#bitmaker"
    currrent_status = get_status

    openSocket()

    @server.puts "USER testing 0 * Testing"
    @server.puts "NICK #{nick}"
    @server.puts "JOIN #{channel}"
    @server.puts "PRIVMSG #{channel} :Github is #{currrent_status}"
    @server.puts "QUIT"

    until @server.eof? do
      msg = @server.gets
      puts msg
    end
  end

  def get_status
    url = 'https://status.github.com/api/status.json'
    data = JSON.parse Curl.get(url).body_str
    return data["status"].to_sym
  end


  protected

  def openSocket
    host = "chat.freenode.net"
    port = "6667"
    @server = TCPSocket.open(host, port)
  end
end