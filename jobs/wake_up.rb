class WakeUp
  include Sidekiq::Worker

  def perform(*args)
    # do something
    puts "Wake Up!"
  end
end
