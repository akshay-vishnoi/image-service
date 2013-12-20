#!/usr/bin/env ruby
# encoding: utf-8

require 'bunny'
require 'debugger'
require_relative 'cropper'

def send_cropped_image_path(params = nil)
  file_info = params || get_image_path
  cropper = Cropper.new(file_info[:path], file_info)
  cropper.save
  cropper.dest_path
end

conn = Bunny.new(:automatically_recover => false)
conn.start

ch   = conn.create_channel
q    = ch.queue('image_cropper')
q2   = ch.queue('image_path')

begin
  puts " [*] Waiting for messages. To exit press CTRL+C"
  q.subscribe(:block => true) do |delivery_info, properties, body|
    cropped_file_path = send_cropped_image_path(YAML.load(body))
    puts " [x] Received #{cropped_file_path}"
    # ch.default_exchange.publish(cropped_file_path, :routing_key => q2.name)
  end
rescue Interrupt => _
  conn.close

  exit(0)
end