# inspiration from
# https://github.com/mperham/sidekiq/wiki/Monitoring#standalone-with-basic-auth

require 'sidekiq'
require 'sidekiq/web'
require './config/sidekiq'

use Rack::Session::Cookie, secret: ENV.fetch('RACK_SESSION_SECRET') , same_site: true, max_age: 86400

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
