require "test/unit"
require_relative "status_bot.rb"

StatusBot.announce "Testing"


class TCPSocketDouble

  attr_reader :last_bot_output

  def puts(input)
    @last_bot_output = input
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
    assert_equal valid_status, true, "Expected status to be either good, minor or major"
  end

  def test_command_response
    @status_bot.respond_to("some_random_irc_stuff PRIVMSG #bitmaker :!statusbot  \n")

    # Verify that the bot responded with a github status
    output = @tcp_double.last_bot_output
    assert_not_nil output
    valid_output = output.include?("Github is ")
    assert_equal valid_output, true
  end

end