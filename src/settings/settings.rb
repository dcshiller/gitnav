require 'git';
require_relative '../git_commands/information'
require_relative '../git_commands/navigation'
require_relative '../git_commands/operation'

class Settings
  attr_reader :view_branch_name, :selected_branch_name

  def initialize
    @view_branch_name = current_branch_name
    @selected_branch_name = nil
    @paused = false
  end

  def next_branch
    current_branch_index = all_branch_names.find_index { |b| b == view_branch_name }
    next_branch_index = (current_branch_index + 1) % all_branch_names.size
    @view_branch_name = all_branch_names.to_a[next_branch_index]
  end

  def prev_branch
    current_branch_index = all_branch_names.find_index { |b| b == view_branch_name }
    prev_branch_index = (current_branch_index - 1) % all_branch_names.size
    @view_branch_name = all_branch_names.to_a[prev_branch_index]
  end

  def select_branch
    if selected_branch_name == view_branch_name
      @selected_branch_name = nil
    else
      @selected_branch_name = view_branch_name
    end
  end

  def delete_branch_if_able
    return unless branch_contains?(view_branch_name, selected_branch_name)
    branch_to_delete = view_branch_name
    prev_branch
    delete_branch branch_to_delete
    clear_cache
    @selected_branch_name = nil
  end

  def save_and_exit
    # Checkout view
    checkout view_branch_name
    exit
  end

  def is_in_view?(branch)
    branch == view_branch_name
  end

  def is_selected?(branch)
    return false unless selected_branch_name
    branch == selected_branch_name
  end

  def is_current_branch?(branch)
    branch == current_branch_name
  end

  def is_paused?
    !!@paused
  end

  def is_not_paused?
    !!@paused
  end

  def pause!
    @paused = true
  end

  def unpause!
    @paused = false
  end
end
