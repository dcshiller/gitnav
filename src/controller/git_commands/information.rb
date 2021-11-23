def current_branch_name
  @current ||= `git symbolic-ref --short HEAD`.chomp
end

def all_branch_names
  @all ||= `git for-each-ref --format='%(refname:short)' refs/heads/`.split("\n").map(&:strip)
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
  @dates_by_branch ||= `git for-each-ref --format='%(committerdate) }:{ %(refname:short)' refs/heads/`.
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

