-- https://github.com/projekt0n/github-nvim-theme

local hi = require("utils.api.hi")

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
    local theme_style = ""
    -- mode
    --获取当日时间戳0点
    local cDateTodayTime = getTodayTimeStamp()
    --当前时间戳
    local cDateCurrectTime = os.time()
    local cDateTodayTime_8 = FormatTime(cDateTodayTime,0,8)
    local cDateTodayTime_19 = FormatTime(cDateTodayTime,0,19)
    if cDateTodayTime_8 < cDateCurrectTime and cDateCurrectTime < cDateTodayTime_19 then
        theme_style = "light"
    else
        theme_style = "dark"
    end

    local ok, m = pcall(require, "github-theme")
    if not ok then
        return
    end

    M.github_theme = m
    M.github_theme.setup({
        -- Theme style to use
        -- theme_style = "dark",
        theme_style = theme_style,
        -- Set the style of treesitter
        comment_style = "NONE",
        function_style = "NONE",
        keyword_style = "NONE",
        variable_style = "NONE",
        -- Feature highlighting
        dark_sidebar = true,
    })
end

function M.after()
    local config = require("github-theme.config")
    -- Apply custom theme highlighting
    require(string.format("configure.theme.github-theme.highlights-%s", config.schema.theme_style)).execute()
end

return M
