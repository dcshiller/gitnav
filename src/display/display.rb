require 'colorize';
require "action_view"
require 'active_support/core_ext/date/conversions'
require 'active_support/core_ext/numeric/time'
require_relative '../git_commands/information'

include ActionView::Helpers::DateHelper

class Display
  attr_reader :win, :error_win
  def initialize
    @win = Curses::Window.new(0, 0, 1, 1)
    @error_win = Curses::Window.new(0, 0, Curses::lines - 3, 1)
  end

  def redraw(settings)
    clear_cache
    win.clear
    win.setpos(0,0)
    branches = all_branch_names
    branch_index = branches.index(settings.view_branch_name) || 0
    branches.slice([branch_index - Curses::lines + 8, 0].max, Curses::lines - 5).each do |branch|
      if settings.is_in_view?(branch)
        add_detailed_branch branch, settings
      else
        add_bare_branch branch, settings
      end
    end
    win.refresh
    error_win.setpos(0,0)
    error_win.addstr(settings.notes[-1])
    error_win.refresh
  end

  def pause!
    @paused = true
  end

  def unpause!
    @paused = false
  end

  private

  def add_detailed_branch(branch, settings)
    # ew_line unless settings.is_paused?
    if (settings.is_current_branch? branch)
      win.attron(color_pair(2)) {
        add(title_line(branch, settings))
      }
    else
      win.attron(color_pair(1)) {
        add(title_line branch, settings)
      }
    end
    new_line
  end

  def add_bare_branch(branch, settings)
    if (settings.is_current_branch? branch)
      win.attron(color_pair(2)) {
        add(title_line branch, settings)
      }
    else
      add(title_line branch, settings)
    end
    new_line
  end

  def title_line(branch, settings)
    suffix = ''
    if settings.is_selected? branch then prefix = '+' end
    [prefix, branch, suffix].compact.join
  end

  def add(string)
    win.addstr(string)
  end

  def new_line
    add("\n")
  end
end
