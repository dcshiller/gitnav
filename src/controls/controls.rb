require 'tty-reader'
require 'byebug'
class Controls
  attr_accessor :settings, :callback
  attr_reader :last_change

  def initialize
    @last_change = nil
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
        settings.select_branch
        handle_change
      elsif event.value == "x"
        settings.delete_branch_if_able
        handle_change
      elsif event.value == "\e[B" or event.value == "j"
        settings.next_branch
        handle_change
      elsif event.value == "\e[A" or event.value == "k"
        settings.prev_branch
        handle_change
      elsif event.value == "\n" or event.value == "\r"
        settings.save_and_exit
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
    settings.pause!
    callback.call if callback
    new_rand = rand(10000)
    @last_change = new_rand
    Thread.new do
      sleep 2
      if new_rand == last_change
        settings.unpause!
        callback.call if callback
      end
    end
  end
end
