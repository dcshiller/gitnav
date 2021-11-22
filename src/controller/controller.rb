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

  def delete_branch_if_able
    err = delete_branch view_branch_name
    if err
      notes.push err
    else
      notes.push "#{view_brach_name} deleted"
      prev_branch
      clear_cache
    end
  end

  def save_and_exit
    checkout view_branch_name
    exit
  end

  def is_in_view?(branch)
    branch == view_branch_name
  end

  def is_current_branch?(branch)
    branch == current_branch_name
  end

  private

  def add_note(note)
    notes << note
  end
end
