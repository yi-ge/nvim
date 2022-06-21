-- https://github.com/Mofiqul/vscode.nvim

local options = require("core.options")

local M = {}

function M.before() end


--获取当日时间戳0点
local function getTodayTimeStamp()
  local cDateCurrectTime = os.date("*t")
  local cDateTodayTime = os.time({year=cDateCurrectTime.year, month=cDateCurrectTime.month, day=cDateCurrectTime.day, hour=0,min=0,sec=0})
  return cDateTodayTime
end

--格式化时间为时间戳
function FormatTime(lastDate,day,hour)
	local dayTimestamp = 24* 60* 60
	lastDate = lastDate + dayTimestamp  *  day
	local date = os.date("*t", time)
	--这里返回的是你指定的时间点的时间戳
	return os.time({year=date.year, month=date.month, day=date.day, hour=hour, minute = date.minute, second = date.second})
end

function M.load()
    -- mode
    --获取当日时间戳0点
    local cDateTodayTime = getTodayTimeStamp()
    --当前时间戳
    local cDateCurrectTime = os.time()
    local cDateTodayTime_8 = FormatTime(cDateTodayTime,0,8)
    local cDateTodayTime_19 = FormatTime(cDateTodayTime,0,19)
    if cDateTodayTime_8 < cDateCurrectTime and cDateCurrectTime < cDateTodayTime_19 then
        vim.g.vscode_style = "light"
    else
        vim.g.vscode_style = "dark"
    end
    -- transparent background
    vim.g.vscode_transparent = options.transparent_background
    -- Enable italic comment
    vim.g.vscode_italic_comment = 0
    -- Disable nvim-tree background color
    vim.g.vscode_disable_nvimtree_bg = true
end

function M.after()
    vim.cmd([[colorscheme vscode]])
    -- custom theme highlighting
    require("configure.theme.vscode.highlights-" .. vim.g.vscode_style).execute()
end

return M
