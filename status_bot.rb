# This is required for connecting to IRC
require "socket"
# These are required for querying Github's API
require 'net/http'
require 'curb'
require 'json'

class StatusBot

  def initialize(server = nil)
    @nick = "BitMakers_StatusBot"
    @channel = "#bitmaker"
    @server = server
  end

  def run!
    openSocket() if @server.nil?

    @server.puts "USER testing 0 * Testing"
    @server.puts "NICK #{@nick}"
    @server.puts "JOIN #{@channel}"

    # REPL: we read each line from IRC, evaluate it and
    # respond if it is a !statusbot command.
    until @server.eof? do
      respond_to @server.gets
    end
  end

  def respond_to(msg)
    puts msg.strip()
    if msg.strip().end_with? "PRIVMSG #{@channel} :!statusbot"
      StatusBot.announce "Status Requested!"

      currrent_status = get_github_status()
      current_time = Time.now().strftime "%l:%M:%S %P"

      @server.puts "PRIVMSG #{@channel} :As of #{current_time} Github is #{currrent_status}"
    end
  end

  def get_github_status
    url = 'https://status.github.com/api/status.json'
    data = JSON.parse Curl.get(url).body_str
    return data["status"].to_sym
  end

  def self.announce(debug_info)
    robot_noises = ['Beep', 'Bop', 'Boop'] * 4

    puts "#{"\n"*1}#{'-'*80}"
    StatusBot.say debug_info
    StatusBot.say robot_noises.sample(4).join(" ") + "!"
    puts "#{'-'*80}#{"\n"*2}"
  end

  def self.say(text)
    green = "\x1B[0;32m"
    reset = "\x1B[0m"

    puts "Status Bot: #{green}#{text}#{reset}"
  end

  protected

  def openSocket
    host = "chat.freenode.net"
    port = "6667"
    @server = TCPSocket.open(host, port)
  end
  
end