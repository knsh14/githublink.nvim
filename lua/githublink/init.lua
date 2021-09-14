
function display(message, level)
    local n = require("notify")
    if n == nil then
        return
    end
    n.setup({
        stages = "slide",
    })
    n(message, level, {
        title = "githublink.nvim",
        timeout = 2000,
    })
    return
end

function getCommitLink(ref_mode, firstline, lastline)
    local currentdir = shellexec("pwd")
    vim.api.nvim_command('lcd %:p:h')
    local ref_name = ""
    if ref_mode == "branch" then
      ref_name = shellexec("git rev-parse --abbrev-ref HEAD")
    elseif ref_mode  == "head" then
      ref_name = shellexec("git rev-parse HEAD")
    elseif ref_mode  == "file" then
      ref_name = shellexec(string.format("git rev-list -1 HEAD -- %s", vim.fn.expand('%')))
    else
      display("unknown ref_mode", "error")
      return
    end
    execute_with_ref(ref_name, firstline, lastline)
    vim.api.nvim_command(string.format('lcd %s', currentdir))
end

function shellexec(cmd)
  local handle = io.popen(cmd)
  local result = handle:read("*a")
  handle:close()
  return result
end

function execute_with_ref(ref, startline, endline)
    local remote = shellexec("git ls-remote --get-url origin")
    if string.find(remote, '.*[github|gitlab].*') == nil then
        display(string.format("%s unsupported remote host", remote), "error")
        return
    end

    local repo = ''
    if string.find(remote, '^git') ~= nil then
        repo = get_repo_url_from_git_protocol(remote)
    elseif string.find(remote, '^ssh') ~= nil then
        repo = get_repo_url_from_ssh_protocol(remote)
    elseif string.find(remote, '^https') ~= nil then
        repo = get_repo_url_from_https_protocol(remote)
    else
        display(string.format("remote %s doesn't match any known protocol", remote), "error")
        return
    end

    local root = shellexec("git rev-parse --show-toplevel")
    root = string.gsub(root, '[\r\n ]', '')
    local p = vim.fn.expand('%:p')
    local s, e = string.find(p, root, 1, true)
    if s == nil or e == nil then
      display(string.format("%s is not found in \n%s", root, p), "error")
      return
    end
    local path_from_root = string.sub(p, tonumber(e)+1, p:len())

    -- https://github.com/OWNER/REPO/blob/BRANCH/PATH/FROM/ROOT#LN-LM
    local baselink = string.format("%s/blob/%s%s", repo, ref, path_from_root)
    local link = ""
    if startline == endline then
        link = string.format("%s#L%d", baselink, startline)
    else
        link = string.format("%s#L%d-L%d", baselink, startline, endline)
    end
    link = string.gsub(link, "[\n\t ]", "")
    vim.cmd(string.format('let @+ = "%s"', link))
    display(string.format("copied %s", link), "info")
end

function get_repo_url_from_git_protocol(uri)
    local host, repo = string.match(uri, '^git@(.*):(.*)$')
    if host == nil or repo == nil then
        display(string.format("%s doesn't match to git protocol uri", uri), "error")
        return ""
    end
    local trimed = trim_git_suffix(repo)
    return string.format("https://%s/%s", host, trimed)
end

function get_repo_url_from_ssh_protocol(uri)
    local host, repo = string.match(uri, '^ssh://git@(.{-})/(.*)$')
    if host == nil or repo == nil then
        display(string.format("%s doesn't match to ssh protocol uri", uri), "error")
        return ""
    end
    local trimed = trim_git_suffix(repo)
    return string.format("https://%s/%s", host, trimed)
end

function get_repo_url_from_https_protocol(uri)
    local host = string.match(uri, '^(https:.*)$')
    if host == nil then
        display(string.format("%s doesn't match to http protocol uri", uri), "error")
        return ""
    end
    local trimed = trim_git_suffix(host)
    return string.format("https://%s", trimed)
end

function trim_git_suffix(str)
    local nospace = string.gsub(str, '[\r\n ]', '')
    return string.gsub(nospace, '%.git$', '')
end

local githublink = {}
githublink.getCommitLink = getCommitLink
return githublink

