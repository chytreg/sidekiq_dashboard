# inspiration from
# https://github.com/mperham/sidekiq/wiki/Monitoring#standalone-with-basic-auth

require "./boot.rb"

use Rack::Session::Cookie, secret: ENV.fetch('RACK_SESSION_SECRET') , same_site: true, max_age: 86400

map '/' do
  if ENV.fetch('SIDEKIQ_USER') && ENV.fetch('SIDEKIQ_PASS')
    use Rack::Auth::Basic, "Protected Area1" do |username, password|
      # Protect against timing attacks: (https://codahale.com/a-lesson-in-timing-attacks/)
      # - Use & (do not use &&) so that it doesn't short circuit.
      # - Use digests to stop length information leaking
      Rack::Utils.secure_compare(::Digest::SHA256.hexdigest(username), ::Digest::SHA256.hexdigest(ENV.fetch('SIDEKIQ_USER'))) &
        Rack::Utils.secure_compare(::Digest::SHA256.hexdigest(password), ::Digest::SHA256.hexdigest(ENV.fetch('SIDEKIQ_PASS')))
    end
  end

  run Sidekiq::Web
end
