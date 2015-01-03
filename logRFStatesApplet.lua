--[[
   log RF States before a reboot is done and set them again after reboot
--]]

module(...,package.seeall)
require ("xap")

info={
   version="1.1", description="log RF States"
}
  
function createINIfile(filename)
	local err
	fho, err = io.open(filename, "w")
	if err then print("Error opening ini-file " .. filename .. " for writing!"); return; end
	fho:write("# personal ini-settings")
    fho:write("\n")
    fho:write("\n")
	fho:write("[rf]")
    fho:write("\n")
	local rfDevices = 10
	for i = 1, rfDevices do
		fho:write("rf" .. i .. "=off")
        fho:write("\n")
	end
	fho:close()
end

	
--[[
This function opens a file and reads it line by line
]]
function readINIfile(filename)
	local err
	local i = 1
	fh, err = io.open(filename)
	if err then 						-- create new ini file
		createINIfile(filename)
		fh, err = io.open(filename)
	end
	i = 1
	while true do
		lines[i] = fh:read()
		if lines[i] == nil then break end
		i = i + 1
	end
	fh:close()
	return i - 1
end


--[[
This function reads a file and writes it back including the modified lines
]]
function writeINIfile(filename, rf, state)
	local linecount = readINIfile(filename)
	local j = 1
	local err
	local rf_changed = false
	fho, err = io.open(filename, "w")
	if err then print("Error opening ini-file " .. filename .. " for writing!"); return; end
	for j = 1, linecount do
        if string.find(lines[j], "rf" .. rf) then
				fho:write("rf" .. rf .. "=", state)
                fho:write("\n")
				rf_changed = true
		else
                fho:write(lines[j])
                fho:write("\n")
		end
	end
	if not rf_changed then	-- new rf to be written into the INI-file
		fho:write("rf" .. rf .. "=", state)
        fho:write("\n")
	end
	fho:close()
end 	
		
		
--[[
This function reads an INI-file and sets the rf-states as read in the ini file
]]
function setrfs(source)
   	local i
	local state
	local j
	local linecount = readINIfile(filename)
	for j = 1, linecount do
		if string.find(lines[j], "rf%d*=") then
		-- print(j)
			i, state = string.match(lines[j], "rf(%d+)=(%a+)")
			xap.sendShort(string.format([[xap-header
{
target=%s%s
class=xAPBSC.cmd
}
output.state.1
{
id=*
state=%s
}]], source, tostring(i), tostring(state)))
		end
	end
end
	
		
function logstate(frame)
		-- Get the relays STATE either on or off
		state = frame:getValue("output.state", "state")
		-- This LUA pattern will parse the source address ie. 'dbzoo.livebox.Controller:rf.1'
		-- From this string extract the rf device id. 
		rf = string.match(frame:getValue("xap-header", "source"), "rf%.(%d+)")
		-- Print out this device's current state
		writeINIfile(filename, rf, state)
		-- print(rf)
end



function init()
--  Watch for a directed message to rf
	lines = {}
	filename = '/etc/xap.d/rf-settings.ini'
	source = 'dbzoo.hal.Controller:rf.'
	setrfs(source)
	f = xap.Filter()
	f:add("xap-header", "source", source .. '*')
	f:add("xap-header", "class", "xAPBSC.event")
	f:callback(logstate)
end