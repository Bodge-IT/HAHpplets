-- Auto Off after 1 hour for BR Fan 
-- 
-- Auth: Gary, 2015

module(...,package.seeall)
require("xap")
require("xap.bsc")

info = {version="0.01", description="Auto Fan Off"}

local rf="dbzoo.hal.Controller:rf.6"
hasRun = nil

function fanOn(frame)
	state=frame:getValue("output.state","State")
	if state=="on" and hasRun == nil then
		bsc.sendState(rf, "on")
		hasRun(os.time())
		xap.Timer(offMsg, 60*60):start()
	end
end

function offMsg(timer)
	bsc.sendState("dbzoo.hal.Controller:rf.6","off")
	timer:delete()
end

function hasRun(when)
	print(when)
end

function init()
	f = xap.Filter()
	f:add ("xap-header","source","ersp.SlimServer.Stargate:Kitchen")
	f:add("xap-header","class","xAPBSC.Event")
	f:callback(fanOn)
end