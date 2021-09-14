githublink.nvim
---

# about
lua implementation of [knsh14/vim-github-link]( https://github.com/knsh14/vim-github-link )  
create GitHub link from selected lines and copy to clipboard

# install

## [packer.nvim]( https://github.com/wbthomason/packer.nvim )
```
use {
  'knsh14/githublink.nvim',
  requires = {'rcarriga/nvim-notify'},
  cmd = {'GetCommitLink', 'GetCurrentBranchLink', 'GetCurrentCommitLink'},
}
```

# depend libraries
[rcarriga/nvim-notify]( https://github.com/rcarriga/nvim-notify ) to show cool popup display
