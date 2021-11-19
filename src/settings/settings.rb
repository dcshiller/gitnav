require 'git';

class Settings
  attr_reader :view_branch, :selected_branch

  def initialize
    @view_branch = branches[g.current_branch]
    @selected_branch = nil
    @paused = false
  end

  def next_branch
    current_branch_index = branches.find_index { |b| b.name == view_branch.name }
    next_branch_index = (current_branch_index + 1) % branches.size
    @view_branch = branches.to_a[next_branch_index]
  end

  def prev_branch
    current_branch_index = branches.find_index { |b| b.name == view_branch&.name }
    prev_branch_index = (current_branch_index - 1) % branches.size
    @view_branch = branches.to_a[prev_branch_index]
  end

  def select_branch
    if selected_branch&.name == view_branch.name
      @selected_branch = nil
    else
      @selected_branch = view_branch
    end
  end

  def delete_branch
    return unless selected_branch&.contains?(@view_branch.name)
    branch_to_delete = @view_branch
    prev_branch
    branch_to_delete.delete
    @selected_branch = nil
    @branches = nil # refresh
  end

  def save_and_exit
    @view_branch.checkout
    exit
  end

  def is_in_view?(branch)
    branch.name == view_branch.name
  end

  def is_selected?(branch)
    return false unless selected_branch
    branch.name == selected_branch.name
  end

  def is_current_branch?(branch)
    branch.name == current_branch.name
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

  private

  def branches
    @branches ||= g.branches
  end

  def g
    @git ||= Git.open('./');
  end

  def current_branch
    @current_branch ||= branches[g.current_branch]
  end
end
