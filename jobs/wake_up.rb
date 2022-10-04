class WakeUp
  include Sidekiq::Worker

  def perform(*args)
    Curl::Easy.perform(ENV.fetch("APP_URL")) do |curl|
      curl.http_auth_types = :basic
      curl.username = ENV.fetch("SIDEKIQ_USER")
      curl.password = ENV.fetch("SIDEKIQ_PASS")
      curl.verbose = true
    end
  end
end
