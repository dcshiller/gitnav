require 'open3'

def delete_branch(branch_name)
  out, err, st = Open3.capture3("git branch -d #{branch_name}")
  return err.split("\n")[0] if err && err.include?('error')
  false
end
