
require 'sidekiq'
require 'sidekiq-cron'
require 'sidekiq/web'
require 'sidekiq/cron/web'

require './config/sidekiq'
Dir["./jobs/*.rb"].each {|file| require file }
