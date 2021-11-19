require 'git';
require 'colorize';
require "action_view"
require 'active_support/core_ext/date/conversions'
require 'active_support/core_ext/numeric/time'

include ActionView::Helpers::DateHelper

class Display
  attr_reader :win
  def initialize
    @win = Curses::Window.new(0, 0, 1, 1)
  end

  def redraw(settings)
    win.setpos(0,0)
    branches = g.branches.local
    branches.each do |branch|
      if settings.is_in_view?(branch)
        add_detailed_branch branch, settings
      else
        add_bare_branch branch, settings
      end
    end
    win.refresh
  end

  def pause!
    @paused = true
  end

  def unpause!
    @paused = false
  end

  private

  def add_detailed_branch(branch, settings)
    new_line unless settings.is_paused?
    if (settings.is_current_branch? branch)
      win.attron(color_pair(2)) {
        add(title_line(branch, settings))
      }
     else
      win.attron(color_pair(1)) {
        add(title_line branch, settings)
      }
     end
    unless settings.is_paused?
      new_line
      add(branch.gcommit.author.name)
      new_line
      time_from = distance_of_time_in_words_to_now(branch.gcommit.date)
      add(time_from + " ago")
      new_line
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
    unless settings.is_paused?
      if settings.is_in_view?(branch)
        size = g.diff(settings.selected_branch&.name || 'master', branch.name).size
        suffix = " (#{size})"
      end
    end
    if settings.is_selected? branch then prefix = '+' end
    [prefix, branch.name, suffix].compact.join
  end

  def g
    @git ||= Git.open('./');
  end

  def add(string)
    win.addstr(string)
  end

  def new_line
    add("\n")
  end
end
