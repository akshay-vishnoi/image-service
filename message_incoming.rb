#!/usr/bin/env ruby
# encoding: utf-8

require 'bunny'

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
  resizer.images
end

def generate_image_according_to_type(params)
  if params[:type] == "crop"
    send_cropped_image_path(params)
  else
    generate_resized_thumbnails(params)
  end
end

conn = Bunny.new(:automatically_recover => false)
conn.start

ch   = conn.create_channel
cropper_queue    = ch.queue('image_cropper')
path_queue   = ch.queue('image_path')

begin
  puts " [*] Waiting for messages. To exit press CTRL+C"
  cropper_queue.subscribe(:block => true) do |delivery_info, properties, body|
    generate_image_according_to_type(YAML.load(body))
  end
rescue Interrupt => _
  conn.close
  exit(0)
end