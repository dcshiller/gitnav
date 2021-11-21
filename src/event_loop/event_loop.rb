# Handles keyboard input and output

require 'tty-reader'
require 'byebug'

class EventLoop
  attr_accessor :controller, :callback

  def initialize(controller)
    @controller = controller
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
      elsif event.value == " "
        controller.select_branch
        handle_change
      elsif event.value == "x"
        controller.delete_branch_if_able
        handle_change
      elsif event.value == "\e[B" or event.value == "j"
        controller.next_branch
        handle_change
      elsif event.value == "\e[A" or event.value == "k"
        controller.prev_branch
        handle_change
      elsif event.value == "\n" or event.value == "\r"
        controller.save_and_exit
        handle_change
      end
    end

    loop do
      # print reader.cursor.clear_line
      reader.read_keypress(nonblock: true)
    end
  end

  private

  def handle_change
    callback.call if callback
  end
end
