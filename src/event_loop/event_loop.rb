# Handles keyboard input and output

require 'tty-reader'
# require 'byebug'

class EventLoop
  attr_reader :controller, :update_callback, :confirm_callback

  def initialize(controller)
    @controller = controller
    @confirm_callback = nil
  end

  def on_update(&block)
    @update_callback = block
  end

  def on_confirm(&block)
    @confirm_callback = block
  end

  def listen
    reader = TTY::Reader.new

    reader.on(:keypress) do |event|
      if event.value == 'y' && confirm_callback != nil
        confirm_callback.call
        handle_change
      end
      controller.clear_notes
      @confirm_callback = nil

      if event.value == 'q'
        close_screen
        exit
      elsif event.value == 'd'
        controller.toggle_data
        handle_change
      elsif event.value == " "
        handle_change
      elsif event.value == "x"
        result = controller.delete_branch_if_able
        if (result && result[:on_confirm])
          on_confirm &result[:on_confirm]
        end
        handle_change
      elsif event.value == "\e[B" or event.value == "j"
        controller.next_branch
        handle_change
      elsif event.value == "\e[A" or event.value == "k"
        controller.prev_branch
        handle_change
      elsif event.value == "\e[C" or event.value == "l"
        controller.save_and_exit
      elsif event.value == "\n" or event.value == "\r"
        controller.checkout_viewed_branch
        handle_change
      elsif event.value == 'n'
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
