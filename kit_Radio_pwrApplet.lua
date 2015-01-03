-- Simple script to turn on Toggle Radio PWR from Squeezebox Remote 
-- 
-- Auth: Gary, 2014

module(...,package.seeall)
require("xap")
require("xap.bsc")

info={version="1.0", description="Radio PWR Toggle"}

local rf="dbzoo.hal.Controller:rf.7"

-- Toggles the state of RF 7
function chnge(cond)
  local state=cond:getValue("output.state","State")
    bsc.sendState(rf, state)
end   
             
-- Gets new state of button and sends it to 'chnge' function above.
function init()
  f = xap.Filter()
  f:add("xap-header","source","ersp.SlimServer.Stargate:Kitchen")
  f:add("xap-header","class","xAPBSC.event")
  f:callback(chnge)
end 
