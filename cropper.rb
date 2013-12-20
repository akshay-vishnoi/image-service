require 'paperclip'

class Cropper

  attr_accessor :crop_x, :crop_y, :width, :height, :src_path, :dest_path, :file

  def initialize(file_path, options={})
    @file_path = file_path
    @file = nil
    options = {:crop_x => 0, :crop_y => 0, :width => 0, :height => 0}.merge(options)
    self.crop_x = options[:crop_x]
    self.crop_y = options[:crop_y]
    self.width  = options[:width]
    self.height = options[:height]
    self.dest_path = "/tmp/new_#{ Time.now.to_s.gsub(' ', '_') }.#{ get_image_extension }"
  end

  def get_image_extension
    @file_path.split('.').last
  end

  def save
    begin
      cropped_image
      true
    rescue Exception => e
      puts e.message
      false
    end
  end

  private
    def copy_file_to_tmp_folder
      file = URI(@file_path).open
      self.src_path = file.to_path  
    end

    def cropped_image
      copy_file_to_tmp_folder
      Paperclip.run('convert', ":src -crop '#{width.to_i}x#{height.to_i}+#{crop_x.to_i}+#{crop_y.to_i}' :dest", {:src => src_path, :dest => dest_path })
      @file = File.open(dest_path)
    end
end