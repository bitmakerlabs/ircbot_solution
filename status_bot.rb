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
    openSocket!() if @server.nil?

    # Setting up our irc user and nick name and connecting to the channel
    @server.puts "USER testing 0 * Testing"
    @server.puts "NICK #{@nick}"
    @server.puts "JOIN #{@channel}"

    # REPL: we read each line from IRC, evaluate it and
    # respond if it is a !statusbot command.
    until @server.eof? do
      respond_to! @server.gets
    end
  end

  def respond_to!(msg)
    puts msg.strip()

    ping = msg.include? "PING"
    return unless msg.strip().end_with? "PRIVMSG #{@channel} :!statusbot" or ping

    if ping
      @server.puts msg.gsub("PING", "PONG")
    else
      StatusBot.log "Status Requested", important: true

      current_time = Time.now().strftime "%l:%M:%S %P"
      github_status = get_github_status()
      heroku_status = get_heroku_status()

      say! "As of #{current_time}:"

      say! "- Github is #{github_status}", indent: 2

      heroku_status.each do |server_type, status|
        say! "- Heroku is #{status} for #{server_type}", indent: 2
      end
    end
  end

  def get_github_status
    url = 'https://status.github.com/api/status.json'
    data = JSON.parse Curl.get(url).body_str
    return data["status"].to_sym
  end

  def get_heroku_status
    url = "https://status.heroku.com/api/v3/current-status"
    data = JSON.parse Curl.get(url).body_str
    return data["status"]
  end

  def self.log(text, opts = {})
    robot_noises = ['Beep', 'Bop', 'Boop'] * 4
    green = "\x1B[0;32m"
    reset = "\x1B[0m"

    if opts[:important] == true
      puts "#{"\n"*1}#{'-'*80}"
      StatusBot.log text
      StatusBot.log robot_noises.sample(4).join(" ") + "!"
      puts "#{'-'*80}#{"\n"*2}"
    else
      puts "Status Bot: #{green}#{text}#{reset}"
    end
  end

  protected

  def openSocket!
    host = "chat.freenode.net"
    port = "6667"
    @server = TCPSocket.open(host, port)
  end

  def say!(msg, opts = {})
    @server.puts "PRIVMSG #{@channel} :#{' '*(opts[:indent]||0)}#{msg}"
  end
end