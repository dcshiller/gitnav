# Instructions for drawing display

require "action_view"
require 'active_support/core_ext/date/conversions'
require 'active_support/core_ext/numeric/time'

include ActionView::Helpers::DateHelper

class Display
  attr_reader :main_panel, :error_panel, :controller

  def initialize(controller)
    @controller = controller
    @main_panel = Curses::Window.new(0, 0, 1, 1)
    @error_panel = Curses::Window.new(0, 0, Curses::lines - 3, 1)
  end

  def redraw
    controller.refresh
    redraw_main_panel
    redraw_error_panel
  end

  private

  def redraw_main_panel
    main_panel.clear
    main_panel.setpos(0,0)
    branches = controller.get_branch_names
    branch_index = branches.index(controller.view_branch_name) || 0
    branches.slice([branch_index - Curses::lines + 8, 0].max, Curses::lines - 5).each do |branch|
      add_branch branch
    end
    main_panel.refresh
  end

  def redraw_error_panel
    error_panel.setpos(0,0)
    error_panel.addstr(controller.notes[-1])
    error_panel.refresh
  end

  def add_branch(branch)
    add(branch_line branch)
    new_line
  end

  def branch_line(branch)
    if (controller.should_show_data?)
      "#{time_ago_in_words controller.get_date(branch)}   #{controller.get_author(branch)}  #{branch}"
    else
      branch
    end
  end

  def add(string)
    main_panel.addstr(string)
  end

  def new_line
    add("\n")
  end
end
