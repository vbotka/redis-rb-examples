#!/usr/bin/ruby
# Tested with ruby 2.3.3, ruby-redis 3.3.3 and redis 4.0.1

require 'redis'

LOG_FILES = ['/var/log/dpkg.log', ]
LOG_SEPARATOR = ' '
CSV_SEPARATOR = ';'

def read_log(log_file, r)
  # This function reads log_file and put the status into the database
  f = File.open(log_file, "r")
  f.each do |line|
    l = line.split(LOG_SEPARATOR)
    word = l[0] + " " + l[1][0..-4]
    r.zincrby(l[2], 1, word)
  end
  f.close
end

def write_csv(status, r)
  # This function reads the database and writes the status CSV file
  f = File.open(status + ".csv", "w")
  l = r.zrange(status, 0, -1, :with_scores => true)
  l.each do |x|
    f.write( x[0] + CSV_SEPARATOR + x[1].to_s + "\n")
  end
  f.close
end

r = Redis.new(host: "localhost", port: 6379, db: 0)
r.flushdb

for log_file in LOG_FILES
  read_log(log_file, r)
end

for status in r.keys
  write_csv(status, r)
end
