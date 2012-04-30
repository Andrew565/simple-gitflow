namespace :git do
  # Call from command line like this: rake git:new_from_prod[new-branch-name] (no quotes needed, but brackets are)
  desc "Create a new branch based off of production"
  task :new_from_prod, [:branch] do |t, args|
    if args[:branch]
      exec "git checkout production && git pull origin production && git checkout -b " + args[:branch]
    else
      p "No branch name specified. Please use a descriptive branch name, then run rake git:new_from_prod[branch-name]."
    end
  end
  
  # Alias for new_from_prod for those, like Andrew, who prefer to use the word 'start'
  desc "Alias for new_from_prod"
  task :start, [:branch] do |t, args|
    exec "rake git:new_from_prod[" + args[:branch] + "]"
  end
  
  # Call from command line like this: rake git:merge_to_staging
  desc "Merge the currently active branch into staging"
  task :merge_to_staging do
    branch = `git symbolic-ref HEAD 2> /dev/null`
    branch.gsub!('refs/heads/', '').strip!
    exec "git checkout staging && git pull origin staging && git merge " + branch + " && git push origin staging && git checkout " + branch unless branch == "production"
  end
  
  # Call from command line like this: rake git:merge_to_prod
  desc "Merge the currently active branch into production"
  task :merge_to_production do
    branch = `git symbolic-ref HEAD 2> /dev/null`
    branch.gsub!('refs/heads/', '').strip!
    if branch != "staging"
      exec "git checkout production && git pull origin production && git merge " + branch + " && git push origin production && git checkout " + branch
    else
      p "Merging to production from staging is verboten. Checkout your feature branch and then run this command again."
    end
  end
  
  # Call from command line like this: rake git:delete_branch[local_branch]
  desc "Delete a specific branch from your local repo"
  task :delete_branch, [:branch] do |t, args|
    exec "git branch -d " + args[:branch]
  end
  
  # Call from command line like this: rake git:delete_remote_branch[remote_branch]
  desc "Delete a specific branch from origin server"
  task :delete_remote_branch, [:branch] do |t, args|
    exec "git push origin :" + args[:branch]
  end
  
  # Call from command line like this: rake git:finish
  desc "Deletes the currently active branch from the local repo and, optionally, the origin server"
  task :finish, [:with_remote] do |t, args|
    args.with_defaults(:with_remote => "false")
    branch = `git symbolic-ref HEAD 2> /dev/null`
    branch.gsub!('refs/heads/', '').strip!
    if !(['staging', 'production'].include? branch)
      if args[:with_remote].to_bool
        exec "git checkout production && rake git:delete_branch[" + branch + "] && rake git:delete_remote_branch[" + branch + "]"
      else
        exec "git checkout production && rake git:delete_branch[" + branch + "]"
      end
    else
      p "You attempted to finish the " + branch + " branch, which would delete it. Please checkout the feature branch you wish to delete, or use rake git:delete_branch[branchname] to delete another branch. Use rake git:delete_remote_branch to delete remotely."
    end
  end
end