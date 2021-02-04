#!/usr/bin/env ruby

require 'stringio'

module Blessings
  @output_stream = StringIO.new
  class << self
    def output_stream=(stream = $stdout)
      @output_stream = stream
    end

    def insert_newline(lines)
      lines.times do
        @output_stream.print("\n")
      end
    end

    def relative_move_to(horizontal, vertical)
      if horizontal.positive?
        @output_stream.print("\e[#{horizontal}C")
      elsif !horizontal.zero?
        @output_stream.print("\e[#{horizontal.abs}D")
      end
      if vertical.positive?
        @output_stream.print("\e[#{vertical}B")
      elsif !vertical.zero?
        @output_stream.print("\e[#{vertical.abs}A")
      end
    end

    def clear_line
      @output_stream.print("\r\e[K")
    end

    def save
      @output_stream.print("\e[s\u001B7")
    end

    def restore
      @output_stream.print("\e[u\u001B8")
    end

    def red
      @output_stream.print("\e[31m")
    end

    def green
      @output_stream.print("\e[32m")
    end

    def yellow
      @output_stream.print("\e[33m")
    end

    def blue
      @output_stream.print("\e[34m")
    end

    def reset_color
      @output_stream.print("\e[0m")
    end

    def horizontal_bar(content, repetitions)
      repetitions.times do
        @output_stream.print(content)
      end
    end

    def vertical_bar(content, repetitions)
      repetitions.times do
        @output_stream.print(content)
        relative_move_to(-content.length, 1)
      end
      relative_move_to(content.length, -1)
    end

    def relative_print_at(content, horizontal, vertical)
      relative_move_to(horizontal, vertical)
      @output_stream.print(content)
    end

    def box(content, space, border, sides = {})
      return nil unless /^\S$/.match?(border)

      side_length = 2 + 2 * space + content.length
      top_square_border(border, side_length) if sides[:top]
      right_square_border(border, side_length) if sides[:right]
      bottom_square_border(border, side_length) if sides[:bottom]
      left_square_border(border, side_length) if sides[:left]
      relative_print_at(content, space + 1, side_length / 2)
      relative_move_to(-content.length - space - 1, (1 - side_length) / 2)
      side_length
    end
  end
  private_class_method def self.top_square_border(border, side_length)
    horizontal_bar(border, side_length)
    relative_move_to(-side_length, 0)
  end

  private_class_method def self.right_square_border(border, side_length)
    relative_move_to(side_length - 1, 0)
    vertical_bar(border, side_length)
    relative_move_to(-side_length, -side_length + 1)
  end

  private_class_method def self.bottom_square_border(border, side_length)
    relative_move_to(0, side_length - 1)
    horizontal_bar(border, side_length)
    relative_move_to(-side_length, -side_length + 1)
  end

  private_class_method def self.left_square_border(border, side_length)
    vertical_bar(border, side_length)
    relative_move_to(-1, -side_length + 1)
  end
end
