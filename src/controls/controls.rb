require 'tty-reader'
require 'byebug'
class Controls
  attr_accessor :settings, :callback

  def initialize

  end

  def on_update(&block)
    @callback = block
  end

  def listen
    reader = TTY::Reader.new

    reader.on(:keypress) do |event|
      if event.value == 'q'
        close_screen
        exit
      elsif event.value == "\e[B" or event.value == "j"
        settings.next_branch
        callback.call if callback
      elsif event.value == "\e[A" or event.value == "k"
        settings.prev_branch
        callback.call if callback
      elsif event.value == "\n" or event.value == "\r"
        settings.save_and_exit
        callback.call if callback
      end
    end

    loop do
      # print reader.cursor.clear_line
      reader.read_keypress(nonblock: true)
    end
  end
end
