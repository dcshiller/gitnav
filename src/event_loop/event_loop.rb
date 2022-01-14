# Handles keyboard input and output

require 'tty-reader'
# require 'byebug'

class EventLoop
  attr_reader :controller, :update_callback, :confirm_callback, :on_filter_mode, :input_callback, :input

  def initialize(controller)
    @controller = controller
    @confirm_callback = nil
    @input_callback = nil
    @input = ''
  end

  def on_update(&block)
    @update_callback = block
  end

  def on_confirm(&block)
    @confirm_callback = block
  end

  def on_input(&block)
    @input_callback = block
  end

  def listen
    reader = TTY::Reader.new

    reader.on(:keypress) do |event|
      if event.value == 'y' && confirm_callback != nil
        confirm_callback.call
        handle_change
      end
      @confirm_callback = nil

      if event.value == '/'
        controller.set_filter_mode !controller.on_filter_mode
        handle_change
      elsif controller.on_filter_mode && event.value == "\u007F"
        controller.delete_last_filter_char
        handle_change
      elsif controller.on_filter_mode && event.value.match(/^[a-zA-Z_-]$/)
        if input_callback != nil
          @input = input + event.value
        else
          controller.add_to_filter event.value
        end
        handle_change
      elsif event.value == 'q'
        close_screen
        exit
      elsif event.value == 'b'
        on_input &controller.add_branch
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
        controller.set_filter_mode false
        controller.next_branch
        handle_change
      elsif event.value == "\e[A" or event.value == "k"
        controller.set_filter_mode false
        controller.prev_branch
        handle_change
      elsif event.value == "\e[C" or event.value == "l"
        controller.save_and_exit
      elsif event.value == "\n" or event.value == "\r"
        if input_callback != nil
          input_callback.call input
          @input_callback = nil
        else
          controller.checkout_viewed_branch
        end
        handle_change
      elsif event.value == 't'
        controller.toggle_sort_by_date
        handle_change
      # if disconfirm, redraw
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
