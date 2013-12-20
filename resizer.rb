require 'paperclip'
require 'debugger'

class Resizer

  attr_accessor :src_path, :dest_path, :file, :styles

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
      images = []
      styles.each do |key, style|
        images << thumbnail_image_for(style)
      end
      images
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

    def thumbnail_image_for(style)
      copy_file_to_tmp_folder
      width, height = style.split("X")
      self.dest_path = "/tmp/new_#{ Time.now.to_i + rand(10000000) }.#{ get_image_extension }"
      Paperclip.run('convert', ":src -resize '#{width.to_i}x#{height.to_i}' :dest", {:src => src_path, :dest => dest_path })
      @file = File.open(dest_path)
    end
end