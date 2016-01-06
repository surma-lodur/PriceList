
require  File.join(File.dirname(__FILE__), '..', 'preis_liste')

module Clockwork
  handler do |job|
    PriceList::Models::Item.refetch_prices
  end

  # handler receives the time when job is prepared to run in the 2nd argument
  # handler do |job, time|
  #   puts "Running #{job}, at #{time}"
  # end

  #every(10.seconds, 'frequent.job')
  #every(3.minutes, 'less.frequent.job')
  every(2.hour, 'check_prices')

  #every(1.day, 'midnight.job', :at => '00:00')
end
