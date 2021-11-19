def current_branch_name
  @current ||= `git symbolic-ref --short HEAD`.chomp
end

def all_branch_names
  @all ||= `git for-each-ref --format='%(refname:short)' refs/heads/`.split("\n").map(&:strip)
end

def branch_contains?(container, containee)
  `git branch --contains #{containee}`.include?(container)
end

def clear_cache
  @current = nil
  @all = nil
end
