require_relative './manager.rb'
require 'curses'
include Curses

class GitNav
  def initialize
    begin
      init_screen
      curs_set 0
      noecho
      start_color
      init_pair(1, 3, 0)
      init_pair(2, 2, 0)
      Manager.new
    ensure
      close_screen
    end
  end
end

GitNav.new
