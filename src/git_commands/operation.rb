def delete_branch(branch_name)
  `git branch -d #{branch_name}`
end
