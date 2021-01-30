require 'git';

class Settings
  attr_reader :view_branch

  def initialize
    g = Git.open('./');
    @view_branch = branches[g.current_branch]
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

  def save_and_exit
    @view_branch.checkout
    exit
  end

  private

  def branches
    g = Git.open('./');
    g.branches
  end
end
