require_relative './time_helper'

class Display
  attr_reader :main_panel, :log_panel, :controller

  def initialize(controller)
    @controller = controller
    @main_panel = Curses::Window.new(0, 0, 1, 1)
    @log_panel = Curses::Window.new(0, 0, Curses::lines - 3, 1)
  end

  def redraw
    controller.refresh
    redraw_main_panel
    redraw_log_panel
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

  def redraw_log_panel
    log_panel.setpos(0,0)
    log_panel.addstr(controller.receiving_text_input?  ? ">#{controller.input_text_string}\n" : "")
    log_panel.addstr(controller.filter_string.length > 0 || controller.on_filter_mode ? "/#{controller.filter_string}\n" : "\n")
    log_panel.addstr(controller.notes[-1])
    log_panel.refresh
  end

  def add_branch(branch)
    if (controller.is_current_branch? branch)
      main_panel.attron(color_pair(2)) {
        add(branch_line(branch))
      }
    elsif (controller.is_view_branch? branch)
      main_panel.attron(color_pair(1)) {
        add(branch_line branch)
      }
    else
      add(branch_line branch)
    end
    new_line
  end

  def branch_line(branch)
    if (controller.should_show_data?)
      "#{time_ago_in_words(controller.get_date(branch)).slice(0, 15).ljust(15)}   #{controller.get_author(branch).slice(0,15).ljust(15)}  #{branch}"
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
