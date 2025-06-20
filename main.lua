-- plugins/quicklook.yazi/main.lua
-- A Yazi plugin: press your mapped key to QuickLook the current selection
-- Copyright (c) 2025, Rui Sun

-- Check OS type
local function file_exists(path)
	local f = io.open(path, "r")
	if f then
		f:close()
		return true
	end
	return false
end

local function detect_os()
	-- Check if there is winver.exe in the system32 directory
	-- If True, then it is Windows
	if file_exists("C:\\Windows\\system32\\winver.exe") then
		return "Windows"
	end

	-- Check if the uname command is available
	local uname_check = os.execute("uname -a > /dev/null 2>&1")
	if uname_check == nil then
		error("Error: uname command not found")
	end

	local uname = io.popen("uname -a 2>/dev/null")
	if uname then
		local result = uname:read("*l")
		uname:close()
		if result then
			local first_word = result:match("^(%S+)")
			if first_word == "Darwin" then
				return "macOS"
			elseif first_word == "Linux" then
				return "Linux"
			else
				return "Other"
			end
		end
	end

	return "Other"
end

-- collect selected files (or hovered if none)
local selected_files = ya.sync(function()
	local tab, paths = cx.active, {}
	for _, u in pairs(tab.selected) do
		paths[#paths + 1] = tostring(u)
	end
	if #paths == 0 and tab.current.hovered then
		paths[1] = tostring(tab.current.hovered.url)
	end
	return paths
end)

-- helper to read plugin state options
local state_option = ya.sync(function(state, attr)
	return state[attr]
end)

-- optional notification
local function notify(msg)
	ya.notify({
		title = "QuickLook",
		content = msg,
		timeout = 3,
		level = "info",
	})
end

-- main entry point
local function entry()
	-- Check if the system is macOS
	local this_os = detect_os()
	if this_os ~= "macOS" then
		ya.notify({
			title = "QuickLook",
			content = "This plugin does not support " .. this_os .. " .",
			timeout = 3,
			level = "error",
		})
		return
	end

	local files = selected_files()
	if #files == 0 then
		return
	end

	local do_notify = state_option("notification")

	for _, f in ipairs(files) do
		-- quote path and run non-blocking
		os.execute("qlmanage -p " .. string.format("%q", f) .. " >/dev/null 2>&1 &")
		-- make the QuickLook window frontmost
		os.execute([[osascript -e 'tell application "System Events" to set frontmost of process "qlmanage" to true']])
	end

	if do_notify then
		notify("Previewed " .. #files .. " file(s)")
	end
end

return {
	-- setup allows user to toggle notification in ~/.config/yazi/plugins/quicklook.toml
	setup = function(state, options)
		if options.showPreviewNotification == nil then
			options.showPreviewNotification = false
		end
		state.notification = options.showPreviewNotification == true
	end,
	entry = entry,
}
