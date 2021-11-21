# Instructions for drawing display

require 'colorize';
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
    redraw_main_panel
    redraw_error_panel
  end

  private

  def redraw_main_panel
    main_panel.clear
    main_panel.setpos(0,0)
    controller.refresh
    branches = all_branch_names
    branch_index = branches.index(controller.view_branch_name) || 0
    branches.slice([branch_index - Curses::lines + 8, 0].max, Curses::lines - 5).each do |branch|
      if controller.is_in_view?(branch)
        add_detailed_branch branch
      else
        add_bare_branch branch
      end
    end
    main_panel.refresh
  end

  def redraw_error_panel
    error_panel.setpos(0,0)
    error_panel.addstr(controller.notes[-1])
    error_panel.refresh
  end

  def add_detailed_branch(branch)
    if (controller.is_current_branch? branch)
      main_panel.attron(color_pair(2)) {
        add(title_line(branch))
      }
    else
      main_panel.attron(color_pair(1)) {
        add(title_line branch)
      }
    end
    new_line
  end

  def add_bare_branch(branch)
    if (controller.is_current_branch? branch)
      main_panel.attron(color_pair(2)) {
        add(title_line branch)
      }
    else
      add(title_line branch)
    end
    new_line
  end

  def title_line(branch)
    suffix = ''
    if controller.is_selected? branch then prefix = '+' end
    [prefix, branch, suffix].compact.join
  end

  def add(string)
    main_panel.addstr(string)
  end

  def new_line
    add("\n")
  end
end
