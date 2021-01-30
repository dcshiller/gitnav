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
    g = Git.open('./');
    branches = g.branches.local
    view_branch = settings.view_branch
    branches.each do |branch|
      if branch.name == view_branch.name
        add_detailed_branch branch
      else
        add_bare_branch branch
      end
    end
    win.refresh
  end

  private

  def add_detailed_branch(branch)
    new_line
    if (branch.name == current_branch.name)
      win.attron(color_pair(2)) {
        add(branch.name)
      }
     else
      win.attron(color_pair(1)) {
        size = g.diff('master', branch.name).size
        add("#{branch.name} (#{size})")
      }
     end
    new_line
    add(branch.gcommit.author.name)
    new_line
    time_from = distance_of_time_in_words_to_now(branch.gcommit.date)
    add(time_from)
    new_line
    new_line
  end

  def add_bare_branch(branch)
    if (branch.name == current_branch.name)
      win.attron(color_pair(2)) {
        add(branch.name)
      }
    else
      add(branch.name)
    end
    new_line
  end

  def current_branch
    g.branches[g.current_branch]
  end

  def g
    Git.open('./');
  end

  def add(string)
    win.addstr(string)
  end

  def new_line
    add("\n")
  end
end
