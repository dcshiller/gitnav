 # Interface for git commands and internal settings

require_relative './git_commands/information'
require_relative './git_commands/navigation'
require_relative './git_commands/operation'

DATE_SORT = '-authordate'
AUTHOR_SORT = 'refname'
class Controller
  attr_reader :view_branch_name, :notes, :should_show_data, :sorting_order

  def initialize
    @view_branch_name = current_branch_name
    @sorting_order = AUTHOR_SORT
    @notes = []
  end

  def refresh
    clear_cache
  end

  def clear_notes
     @notes = []
  end

  def next_branch
    current_branch_index = get_branch_names.find_index { |b| b == view_branch_name }
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
        return {
          on_confirm: proc {
          delete_branch_if_able true
        } }
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
     all_branch_names sorting_order
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
     if (sorting_order == DATE_SORT)
       @sorting_order = AUTHOR_SORT
     else
       @sorting_order = DATE_SORT
     end
  end

  def should_show_data?
    should_show_data
  end

  private

  def add_note(note)
    notes << note
  end
end
