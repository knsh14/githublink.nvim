if exists('g:githublink')
  finish
endif
let g:githublink = 1

command! -range GetCommitLink <line1>,<line2>call githublink#get("file")
command! -range GetCurrentBranchLink <line1>,<line2>call githublink#get("branch")
command! -range GetCurrentCommitLink <line1>,<line2>call githublink#get("head")
