# Handles keyboard input and output

require 'tty-reader'
require 'byebug'

class EventLoop
  attr_reader :controller, :update_callback

  def initialize(controller)
    @controller = controller
  end

  def on_update &block
    @update_callback = block
  end

  def listen
    reader = TTY::Reader.new

    reader.on(:keypress) do |event|
      if event.value == 'y' && controller.awaiting_confirmation?
        controller.confirm!
        handle_change
      elsif controller.awaiting_confirmation?
        controller.disconfirm!
        handle_change
      end

      if event.value == '/'
        controller.toggle_filter_mode
        handle_change
      elsif controller.receiving_input? && event.value == "\u007F"
        controller.delete_input
        handle_change
      elsif controller.receiving_input? && event.value.match(/^[a-zA-Z_-]$/)
        controller.add_input event.value
        handle_change
      elsif event.value == 'q'
        close_screen
        exit
      elsif event.value == 'b'
        controller.add_branch
        handle_change
      elsif event.value == 'd'
        controller.toggle_data
        handle_change
      elsif event.value == " "
        handle_change
      elsif event.value == "x"
        result = controller.delete_branch_if_able
        handle_change
      elsif event.value == "\e[B" or event.value == "j"
        controller.toggle_filter_mode false
        controller.next_branch
        handle_change
      elsif event.value == "\e[A" or event.value == "k"
        controller.toggle_filter_mode false
        controller.prev_branch
        handle_change
      elsif event.value == "\e[C" or event.value == "l"
        controller.save_and_exit
      elsif event.value == "\n" or event.value == "\r"
        if controller.receiving_input?
          controller.enter_input!
        else
          controller.checkout_viewed_branch
        end
        handle_change
      elsif event.value == 't'
        controller.toggle_sort_by_date
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
    update_callback.call if update_callback
  end
end
