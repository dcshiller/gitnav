require_relative 'display/display'
require_relative 'controller/controller'
require_relative 'event_loop/event_loop'

class Manager
  def initialize
    controller = Controller.new
    display = Display.new
    event_loop = EventLoop.new
    event_loop.controller = controller
    display.redraw controller
    event_loop.on_update {
      display.redraw controller
    }
    event_loop.listen
  end
end

