require_relative 'display/display'
require_relative 'controller/controller'
require_relative 'event_loop/event_loop'

class Manager
  def initialize
    controller = Controller.new
    display = Display.new controller
    event_loop = EventLoop.new controller
    display.redraw
    event_loop.on_update {
      display.redraw
    }
    event_loop.listen
  end
end

