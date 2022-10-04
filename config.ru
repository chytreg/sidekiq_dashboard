# inspiration from
# https://github.com/mperham/sidekiq/wiki/Monitoring#standalone-with-basic-auth

require 'sidekiq'

Sidekiq.configure_client do |config|
  config.redis = {
    url: ENV.fetch('REDIS_URL','redis://localhost:6379'),
    size: 1
  }
end
use Rack::Session::Cookie, secret: "30a06c8eeed7c03930ca7815c469737c94c53148cbad2ca921c2fcfcfd9e48fb", same_site: true, max_age: 86400
require 'sidekiq/web'

map '/' do
  if ENV['USERNAME'] && ENV['PASSWORD']
    use Rack::Auth::Basic, "Protected Area" do |username, password|
      # Protect against timing attacks: (https://codahale.com/a-lesson-in-timing-attacks/)
      # - Use & (do not use &&) so that it doesn't short circuit.
      # - Use digests to stop length information leaking
      Rack::Utils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV["USERNAME"])) &
        Rack::Utils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV["PASSWORD"]))
    end
  end

  run Sidekiq::Web
end
