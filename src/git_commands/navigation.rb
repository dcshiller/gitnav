require_relative './information'

def checkout(branch_name)
  `git checkout #{branch_name}`
  clear_cache
end
