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
    self.dest_path = @file_path.gsub('original', 'cropped')
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
      file = URI.send(:open, @file_path)
      self.src_path = file.to_path
    end

    def cropped_image
      copy_file_to_tmp_folder
      cropped_image_path = "#{src_path.split('original')[0]}/cropped"
      if File.exists?(cropped_image_path)
        FileUtils.rm_rf("#{cropped_image_path}/.", secure: true)
      else
        Dir.mkdir(File.join(src_path.split('original')[0], 'cropped'), 0700)
      end
      Paperclip.run('convert', ":src -crop '#{width.to_i}x#{height.to_i}+#{crop_x.to_i}+#{crop_y.to_i}' :dest", {:src => src_path, :dest => dest_path })
      @file = File.open(dest_path)
    end
end