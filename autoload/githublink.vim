function! githublink#get(ref) range
    call luaeval('require("githublink").getCommitLink(_A[1], _A[2], _A[3])', [a:ref, a:firstline, a:lastline])
endfunction
