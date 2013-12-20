require 'paperclip'
require 'debugger'

class Resizer

  attr_accessor :src_path, :dest_path, :file, :styles, :images

  def initialize(options={})
    @file_path = options[:path]
    @file = nil
    @styles = options[:styles]
  end

  def get_image_extension
    @file_path.split('.').last
  end

  def save
    begin
      self.images = []
      styles.each do |key, style|
        style_path = "#{@file_path.split('original')[0]}#{key}"
        self.dest_path = "#{style_path}/#{@file_path.split('/').last}"
        self.images << thumbnail_image_for(style, style_path)
      end
      self.images
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

    def thumbnail_image_for(style, style_path)
      copy_file_to_tmp_folder
      width, height = style.split("X")
      if File.exists?(style_path)
        FileUtils.rm_rf("#{style_path}/.", secure: true)
      else
        Dir.mkdir(File.join(style_path), 0700)
      end
      Paperclip.run('convert', ":src -resize '#{width.to_i}x#{height.to_i}' :dest", {:src => src_path, :dest => dest_path })
      @file = File.open(dest_path)
    end
end