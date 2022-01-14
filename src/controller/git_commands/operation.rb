require 'open3'

def delete_branch(branch_name, force = false)
  out, err, st = Open3.capture3("git branch -#{force ? 'D' : 'd'} #{branch_name}")
  return err.split("\n")[0] if err && err.include?('error')
  false
end

def create_branch(branch_name, start_point)
  Open3.capture3("git branch #{branch_name} #{start_point}")
end
