require 'java'

import java.awt.Rectangle
import java.awt.Toolkit

import javax.imageio.ImageIO

module Shortcut
  class Screen
    def initialize(opts = {})
      dim = Toolkit.get_default_toolkit.get_screen_size
      opts = {:x => 0, :y => 0, :width => dim.get_width, :height => dim.get_height}.merge(opts)
      rectangle = Rectangle.new(opts[:x], opts[:y], opts[:width], opts[:height])

      @robot = Robot.new
      @image = @robot.create_screen_capture(rectangle)
    end

    def save_image(pathname)
      file = java::io::File.new(pathname)
      ImageIO.write(@image, "PNG", file)
    end

    def get_color(x, y)
      @image.getRGB(x, y)
    end

    def get_color_hex(x, y)
      color = get_color(x, y)
      sprintf("%02X%02X%02X", (color >> 16) & 0xFF, (color >> 8) & 0xFF, color & 0xFF)
    end

    def find_template(template)
      for x in 0...(@image.getWidth - template.getWidth)
        for y in 0...(@image.getHeight - template.getHeight)
          if loop_through_template(template, x, y)
            return Point.new(x, y)
          end
        end
      end

      raise "Couldn't find the game board!\nIs the game on the screen?"
    end

    private

    def loop_through_template(template, x, y)
      for i in 0...template.getWidth
        for j in 0...template.getHeight
          return false if get_color(x+i, y+j) - template.getRGB(i, j) != 0
        end
      end

      return true
    end
  end
end
