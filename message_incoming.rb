#!/usr/bin/env ruby
# encoding: utf-8

require 'bunny'
require 'debugger'

require_relative 'cropper'
require_relative 'resizer'

def send_cropped_image_path(params = nil)
  file_info = params || get_image_path
  cropper = Cropper.new(file_info[:path], file_info)
  cropper.save
  cropper.dest_path
end

def generate_resized_thumbnails(message_body = nil)
  resizer = Resizer.new(message_body)
  resizer.save
  resizer.dest_path
end

def determine_type(params)
  if params[:type] == "crop"
    cropped_file_path = send_cropped_image_path(params)
    puts " [x] Received #{cropped_file_path}"
  else
    thumbnail_files = generate_resized_thumbnails params
    puts " [x] Received #{thumbnail_files}"
  end
end

conn = Bunny.new(:automatically_recover => false)
conn.start
ch  = conn.create_channel
q   = ch.queue('image_cropper')
q2  = ch.queue('image_path')

begin
  puts " [*] Waiting for messages. To exit press CTRL+C"
  q.subscribe(:block => true) do |delivery_info, properties, body|
    determine_type(YAML.load(body))
  end
rescue Interrupt => _
  conn.close
  exit(0)
end