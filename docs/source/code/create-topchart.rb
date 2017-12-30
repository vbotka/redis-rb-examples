#!/usr/bin/ruby
# Tested with ruby 2.3.3, ruby-redis 3.3.3 and redis 4.0.1

require 'redis'

FILE = 'redis.txt'

r = Redis.new(host: "localhost", port: 6379, db: 0)
r.flushdb

f = File.open(FILE, "r")
f.read.scan(/\w+/).each { |word| r.zincrby("topchart", 1, word)}

ranking = r.zrange("topchart", -10, -1, :with_scores => true)

for x in ranking
  puts ( x[1].to_s + " " + x[0] )
end
