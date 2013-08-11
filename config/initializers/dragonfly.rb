# config/initializers/dragonfly.rb

module Dragonfly
  # Supports ImageMagick 6.2.8
  module ImageMagick
    class Processor
      alias_method :_crop, :crop

      def crop(temp_object, opts={})
        # 6.2.8 doesn't support ^^
        if opts[:resize].include?("^^")
          img_opts = identify(temp_object)
          width, height = opts[:width].to_i, opts[:height].to_i
          cols, rows = img_opts[:width], img_opts[:height]
          scale = [width/cols.to_f, height/rows.to_f].max
          cols = (scale * (cols + 0.5)).round
          rows = (scale * (rows + 0.5)).round
          opts[:resize] = "#{cols}x#{rows}"
        end
        _crop(temp_object, opts)
      end
    end

    module Utils
      def identify(temp_object)
        # 6.2.8 doesn't return bit depth
        format, width, height, depth = raw_identify(temp_object).scan(/([A-Z0-9]+) (\d+)x(\d+) .+ (?:(\d+)-bit)?/)[0]
        depth ||= 8
        {
          :format => format.downcase.to_sym,
          :width => width.to_i,
          :height => height.to_i,
          :depth => depth.to_i
        }
      end
    end
  end
end