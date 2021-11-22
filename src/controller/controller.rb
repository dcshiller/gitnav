 # Interface for git commands and internal settings

require_relative './git_commands/information'
require_relative './git_commands/navigation'
require_relative './git_commands/operation'

class Controller
  attr_reader :view_branch_name, :notes

  def initialize
    @view_branch_name = current_branch_name
    @notes = []
  end

  def refresh
    clear_cache
  end

  def clear_notes
     @notes = []
  end

  def next_branch
    current_branch_index = all_branch_names.find_index { |b| b == view_branch_name }
    next_branch_index = (current_branch_index + 1) % all_branch_names.size
    @view_branch_name = all_branch_names.to_a[next_branch_index]
  end

  def prev_branch
    current_branch_index = all_branch_names.find_index { |b| b == view_branch_name } || 0
    prev_branch_index = (current_branch_index - 1) % all_branch_names.size
    @view_branch_name = all_branch_names.to_a[prev_branch_index]
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

  def is_in_view?(branch)
    branch == view_branch_name
  end

  def is_current_branch?(branch)
    branch == current_branch_name
  end

  def get_branch_names
     all_branch_names
  end

  private

  def add_note(note)
    notes << note
  end
end
