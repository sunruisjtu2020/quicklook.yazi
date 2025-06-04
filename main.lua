-- plugins/quicklook.yazi/main.lua
-- A Yazi plugin: press your mapped key to QuickLook the current selection
-- Copyright (c) 2025, Rui Sun

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
		state.notification = options.notification and true
	end,
	entry = entry,
}
