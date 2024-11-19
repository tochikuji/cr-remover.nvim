-- A Neovim plugin to automatically remove unnecessary carriage returns (^M) from buffer
local M = {}
M.config = {
    auto_remove_on_save = true,
    auto_remove_on_paste = true,
    exclude_patterns = {},
    debug = false
}

local function remove_carriage_returns()
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    local modified = false

    for i, line in ipairs(lines) do
        if line:match("%S") then
            local new_line = line:gsub("\r+$", "")
            if new_line ~= line then
                lines[i] = new_line
                modified = true
            end
        end
    end

    if modified then
        vim.api.nvim_buf_set_lines(0, 0, -1, false, lines)
        if M.config.debug then
            print("cr-remover: Removed carriage returns")
        end
    end
end

local function should_process()
    local filename = vim.fn.expand("%:t")
    for _, pattern in ipairs(M.config.exclude_patterns) do
        if filename:match(pattern) then
            return false
        end
    end

    return true
end

local function remove_cr_in_region(start_line, end_line)
    local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
    local modified = false

    for i, line in ipairs(lines) do
        if line:match("%S") then
            local new_line = line:gsub("\r+$", "")
            if new_line ~= line then
                lines[i] = new_line
                modified = true
            end
        end
    end

    if modified then
        vim.api.nvim_buf_set_lines(0, start_line - 1, end_line, false, lines)
        if M.config.debug then
            print("cr-remover: Removed carriage returns in region")
        end
    end
end

function M.setup(opts)
    M.config = vim.tbl_deep_extend("force", M.config, opts or {})

    local augroup = vim.api.nvim_create_augroup("CRRemover", { clear = true })

    if M.config.auto_remove_on_save then
        vim.api.nvim_create_autocmd("BufWritePre", {
            group = augroup,
            callback = function()
                if should_process() then
                    remove_carriage_returns()
                end
            end,
        })
    end

    if M.config.auto_remove_on_paste then
        vim.api.nvim_create_autocmd("TextYankPost", {
            group = augroup,
            callback = function()
                if should_process() then
                    vim.schedule(function()
                        local cur_line = vim.api.nvim_win_get_cursor(0)[1]
                        local start_line = math.max(1, cur_line - 10)
                        local end_line = math.min(vim.api.nvim_buf_line_count(0), cur_line + 10)
                        remove_cr_in_region(start_line, end_line)
                    end)
                end
            end,
        })

        vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
            group = augroup,
            callback = function()
                if should_process() then
                    local cur_line = vim.api.nvim_win_get_cursor(0)[1]
                    local start_line = math.max(1, cur_line - 10)
                    local end_line = math.min(vim.api.nvim_buf_line_count(0), cur_line + 10)
                    remove_cr_in_region(start_line, end_line)
                end
            end,
        })
    end
end

function M.remove_cr()
    remove_carriage_returns()
end

vim.api.nvim_create_user_command("RemoveCR", M.remove_cr, {})

return M
