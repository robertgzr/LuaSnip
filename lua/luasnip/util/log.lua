-- just to be sure this dir exists.
-- 448 = 0700
vim.loop.fs_mkdir(vim.fn.stdpath("log"), 448)

local log_location = vim.fn.stdpath("log") .. "/luasnip.log"

local luasnip_log_fd = vim.loop.fs_open(
	log_location,
	-- only append.
	"a",
	-- 420 = 0644
	420)

local logsize = vim.loop.fs_fstat(luasnip_log_fd).size
if logsize > 50*2^20 then
	print("Luasnip's log now takes up more than 50MiB. Consider deleting it at " .. log_location)
end

local function log_line_append(msg)
	msg = msg:gsub("\n", "\n      | ")
	vim.loop.fs_write(luasnip_log_fd, msg .. "\n")
end

local log = {
	warn = function(msg)
		log_line_append("WARN  | " .. msg)
	end,
	info = function(msg)
		log_line_append("INFO  | " .. msg)
	end,
	error = function(msg)
		log_line_append("ERROR | " .. msg)
	end,
	debug = function(msg)
		log_line_append("DEBUG | " .. msg)
	end
}

log.info("New session: " .. os.date())

local M = {}

function M.new(module_name)
	local module_log = { }
	for name, _ in pairs(log) do
		module_log[name] = function(msg, ...)
			log[name](module_name .. ": " .. msg:format(...))
		end
	end
	return module_log
end

return M
