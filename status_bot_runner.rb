require_relative "status_bot.rb"

StatusBot.log "Initializing", important: true

puts StatusBot.new().run!