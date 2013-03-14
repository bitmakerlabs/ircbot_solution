require "test/unit"
require_relative "status_bot.rb"

StatusBot.log "Testing", important: true


class TCPSocketDouble

  attr_reader :bot_output

  def initialize
    @bot_output = []
  end

  def puts(input)
    @bot_output << input
  end

end


class TestMyRackApplication < Test::Unit::TestCase

  def setup
    @tcp_double = TCPSocketDouble.new()
    @status_bot = StatusBot.new(@tcp_double)
  end

  def test_github_statuses
    status = @status_bot.get_github_status()
    valid_status = [:good, :minor, :major].include?(status)
    assert_equal valid_status, true, "Expected github's status to be either good, minor or major"
  end

  def test_heroku_statuses
    status = @status_bot.get_heroku_status()
    valid_status = status.has_key?("Production") and status.has_key?("Development")

    assert_equal valid_status, true, "Expected heroku's status to include both a production and development key"
  end

  def test_command_response
    @status_bot.respond_to!("some_random_irc_stuff PRIVMSG #bitmaker :!statusbot  \n")

    # Verify that the bot responded with a github status
    out = @tcp_double.bot_output
    valid_output = out[-3].include?("Github") and out[-1].include?("Heroku")
    assert_equal valid_output, true
  end


  def test_ping_response
    @status_bot.respond_to!("PING :holmes.freenode.net")

    # Verify that the bot responded with a github status
    out = @tcp_double.bot_output.last
    assert_equal out, "PONG :holmes.freenode.net"
  end
end