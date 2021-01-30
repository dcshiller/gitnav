require_relative 'display/display'
require_relative 'settings/settings'
require_relative 'controls/controls'

class Manager
  def initialize
    settings = Settings.new
    display = Display.new
    controls = Controls.new
    controls.settings = settings
    display.redraw settings
    controls.on_update {
      display.redraw settings
    }
    controls.listen
  end
end

