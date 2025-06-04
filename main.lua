-- plugins/quicklook.yazi/main.lua
-- Default key: "Q"
-- Override by setting `quicklook_key` in your ~/.config/yazi/init.lua
-- Only support macOS, not for Windows or Linux

-- Read user override key or fall back to "Q"
local key = rawget(_G, "quicklook_key") or "Q"

-- Define a new command "quicklook"
ya.command("quicklook", function()
	local f = fs.current()
	if not f or not f.path then
		return
	end
	-- Launch the Quick Look preview for the current file
	os.execute("qlmanage -p " .. string.format("%q", f.path) .. " &")
end)

-- Bind the command to the manager layer using the chosen key
ya.key("manager", key, "quicklook")
