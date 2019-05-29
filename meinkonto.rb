#!/usr/bin/env ruby

require 'json'
require File.dirname(__FILE__) + '/lib/meinelba.rb'

# ./meinkonto.rb <verfügerKennung><verfüger> <pin>
# ./meinkonto.rb ELVIE33V0V987654 12345
user = ARGV[0] || false
pass = ARGV[1] || false

account = MeinELBA.new(user, pass)

puts "-- access token:", account.accessToken
