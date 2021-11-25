require 'date'
require_relative '../constants'

def current_branch_name
  @current ||= `git symbolic-ref --short HEAD`.chomp
end

def all_branch_names(sorting_order)
  @all ||= sort_in_git?(sorting_order) ?
    `git for-each-ref --sort=#{sorting_order} --format='%(refname:short)' refs/heads/`.split("\n").map(&:strip)
    : sort_in_ruby(sorting_order, `git for-each-ref --format='%(refname:short)' refs/heads/`.split("\n").map(&:strip))
end

def branch_contains?(container, containee)
  `git branch --contains #{containee}`.include?(container)
end

def authors_by_branch
  @authors_by_branch ||= `git for-each-ref --format='%(authorname) }:{ %(refname:short)' refs/heads/`.
    split("\n").
    reduce({}) do |accum, next_line|
    author, branch = next_line.split(' }:{ ').map(&:strip)
      accum[branch] = author
      accum
    end
end

def dates_by_branch
  @dates_by_branch ||= `git for-each-ref --format='%(authordate) }:{ %(refname:short)' refs/heads/`.
    split("\n").
    reduce({}) do |accum, next_line|
    date, branch = next_line.split(' }:{ ').map(&:strip)
    accum[branch] = DateTime.parse date
      accum
    end
end

def clear_cache
  @current = nil
  @all = nil
  @authors_by_branch = nil
end

private

def sort_in_git?(sorting_order)
  sorting_order ==  NAME_SORT || sorting_order == DATE_SORT
end

def sort_in_ruby(sorting_order, branches)
  if (!sorting_order)
    branches
  elsif sorting_order === VISIT_SORT
    sort_by_visit(branches)
  end
end

def sort_by_visit(branches)
    ref_history = `git reflog`.split("\n").map do |line|
      match = /moving from .* to (.*)/.match(line)
      match && match[1]
    end.compact.uniq
    branches.sort_by { |a,b| ref_history.index(a) || ref_history.size <=> ref_history.index(b) || ref_history.size }
end
