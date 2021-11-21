require_relative 'display/display'
require_relative 'controller/controller'
require_relative 'controls/controls'

class Manager
  def initialize
    controller = Controller.new
    display = Display.new
    controls = Controls.new
    controls.controller = controller
    display.redraw controller
    controls.on_update {
      display.redraw controller
    }
    controls.listen
  end
end

