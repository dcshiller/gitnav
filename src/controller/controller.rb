 # Interface for git commands and internal settings

require_relative './git_commands/information'
require_relative './git_commands/navigation'
require_relative './git_commands/operation'
require_relative './constants'

class Controller
  attr_reader :view_branch_name,
    :handle_confirm,
    :handle_input_done,
    :notes, :should_show_data, :sorting_order, :filter_string, :mode, :input_text_string

  def initialize
    @view_branch_name = current_branch_name
    @sorting_order = NAME_SORT
    @notes = []
    @filter_string = ''
    @mode = nil
    @input_text_string = ''
    @handle_input_done = nil
    @handle_confirm = nil
  end

  def refresh
    clear_cache
  end

  def clear_notes
     @notes = []
  end

  def next_branch
    current_branch_index = get_branch_names.find_index { |b| b == view_branch_name } || 0
    next_branch_index = (current_branch_index + 1) % get_branch_names.size
    @view_branch_name = get_branch_names.to_a[next_branch_index]
  end

  def prev_branch
    current_branch_index = get_branch_names.find_index { |b| b == view_branch_name } || 0
    prev_branch_index = (current_branch_index - 1) % get_branch_names.size
    @view_branch_name = get_branch_names.to_a[prev_branch_index]
  end

  # Delete branch. If not merged, ask for confirmation then force.
  def delete_branch_if_able(force = false)
    err = delete_branch view_branch_name, force
    if err
      notes.push err + "\nForce? y/n"
    else
      notes.push "#{view_branch_name} deleted"
      prev_branch
      clear_cache
    end
    if (!force && err)
      @handle_confirm = proc {
        delete_branch_if_able true
      }
    end
  end

  def checkout_viewed_branch
    checkout view_branch_name
  end

  def save_and_exit
    checkout_viewed_branch
    exit
  end

  def is_view_branch?(branch)
    branch == view_branch_name
  end

  def is_current_branch?(branch)
    branch == current_branch_name
  end

  def get_branch_names
    branch_names = all_branch_names sorting_order
    branch_names.filter do |name|
       name.include? filter_string
    end
  end

  def get_author(branch)
     authors_by_branch[branch]
  end

  def get_date(branch)
     dates_by_branch[branch]
  end

  def toggle_data
     @should_show_data = !should_show_data
  end

  def toggle_sort_by_date
    sorts = [NAME_SORT, VISIT_SORT, DATE_SORT]
    @sorting_order = sorts[(sorts.index(sorting_order) + 1) % sorts.size]
  end

  def should_show_data?
    should_show_data
  end

  def add_to_filter(letter)
    @filter_string += letter
  end

  def delete_last_filter_char()
    if filter_string.length == 0
      set_mode nil
    else
      @filter_string = filter_string.slice(0, filter_string.length - 1) || ''
    end
  end

  def delete_last_input_char()
    if input_text_string.length == 0
      set_mode nil
      @handle_input_done = nil
    else
      @input_text_string = input_text_string.slice(0, input_text_string.length - 1) || ''
    end
  end

  def set_mode(value)
    @mode = value
  end

  def toggle_filter_mode value = nil
    if value != nil
      @mode = value
      return
    end
    if mode != 'input' && mode != 'filter'
      @mode = 'filter'
    elsif mode == 'filter'
      @mode = nil
    end
  end

  def on_filter_mode
    mode == 'filter'
  end

  def on_input_mode
    mode == 'input'
  end

  def add_branch
    @mode = 'input'
    @handle_input_done = proc {
      create_git_branch input_text_string, view_branch_name
      @view_branch_name = input_text_string
      @input_text_string = ''
      @mode = nil
    }
  end

  def add_input(input)
    if on_filter_mode
      add_to_filter input
    elsif on_input_mode
      add_to_input_text input
    end
  end

  def delete_input
    if on_filter_mode
      delete_last_filter_char
    elsif on_input_mode
      delete_last_input_char
    end
  end

  def add_to_input_text char
    @input_text_string += char
  end

  def awaiting_confirmation?
    !!handle_confirm
  end

  def receiving_input?
   !!handle_input_done
  end

  def enter_input!
    handle_input_done.call
    @handle_input_done = nil
  end

  def confirm!
    handle_confirm.call
    @handle_confirm = nil
  end

  def disconfirm!
    @handle_confirm = nil
  end

  private

  def add_note(note)
    notes << note
  end
end
