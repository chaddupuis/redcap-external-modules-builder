# RedCap External Modules Builder and Dependencies Resolver

This creates a modules folder (./modules/) from your requested redcap external modules, including running composer on them for any missing dependencies.  This directory can then be pulled into a containerized setup or copied into a server depending on your system setup.

To update External Module versions.
- Edit ext-modules-fetch.sh and update the version number for the module(s) you want to change:
- The version number should be without a "v" (ie just the number).  Some external module repos have a "v", some don't, the script resolves this for you.

Example (the array is version, final directory base name, repo name):
```
### Giftcard Reward
giftcard_reward=("3.2" "giftcard_reward" "https://github.com/susom/redcap-em-giftcard-reward.git")
clone_module_repo_branch_and_move_clean "${giftcard_reward[@]}"
```

So this will grab the 3.2 tag version from the susom giftcard repo and put the files in the directory /modules/giftcard_reward_v###/...


NOTE (Docker Required):  The ext-modules-fetch program also spins up a temporary php8/alpine container to run php compose on all modules to pull in any missing dependencies.  The command, via the docker compose file, it runs is 
```
command:  sh -c 'cd /usr/app/modules && find . -type d -name "*_*" -exec /usr/local/bin/composer -d {} install \; && find . -type d -name "*_*" -exec /usr/local/bin/composer -d {} update \;'

```


