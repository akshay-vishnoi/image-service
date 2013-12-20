#!/usr/bin/env ruby
# encoding: utf-8

require 'bunny'
require 'yaml'

conn = Bunny.new(:automatically_recover => false)
conn.start

ch   = conn.create_channel
q    = ch.queue("image_dimensions")
q2   = ch.queue('image_path')

data = {
  path: 'http://gardenplansandlayouts.landscapeideasanddesign.com/images/landscaping-1.jpg',
  height: 500,
  width: 500,
  crop_x: 100,
  crop_y: 100
}

ch.default_exchange.publish(data.to_yaml, :routing_key => q.name)
puts " [x] Sent Image description"

begin
  puts " [*] Waiting for messages. To exit press CTRL+C"
  q2.subscribe(:block => true) do |delivery_info, properties, body|
    puts " [x] Received file path - #{body}"
    conn.close
  end
rescue Interrupt => _
  conn.close

  exit(0)
end

conn.close