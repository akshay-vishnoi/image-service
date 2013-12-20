require_relative 'cropper'

class ImageService
  def initialize
  end

  def get_image_path 
    file_info = {}
    [:path, :width, :height, :crop_x, :crop_y].each do |attribute_type|
      puts "Enter File #{ attribute_type }"
      file_info[attribute_type] = gets.chomp
    end
    file_info
  end

  def send_cropped_image_path(params = nil)
    file_info = params || get_image_path
    cropper = Cropper.new(file_info[:path], file_info)
    cropper.save
    cropper.dest_path
  end

  def call env
    params = Rack::Utils.parse_query(env['QUERY_STRING']).symbolize_keys
    cropped_file_path = send_cropped_image_path(params)
    [200, { 'Content-Type' => 'application/json' }, [{ :cropped_file_path => cropped_file_path }.to_json]]
  end

  def each; end
end