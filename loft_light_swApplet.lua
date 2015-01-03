-- Very simple script to turn on Light if CC2 @500 
-- 
-- Auth: Gary, 2010

module(...,package.seeall)
require("xap")
require("xap.bsc")

info={version="1.0", description="Loft Light Toggle"}

local light="dbzoo.hal.Controller:rf.5"

-- Toggles the state of RF 5
function chnge(cond)
  local state=cond:getValue("input.state","state")
  bsc.sendState(light, state)
 
--  xap.sendShort(string.format([[xap-header
 --   {
 --   target=dbzoo.hal.Controller:rf.5
--    class=xAPBSC.cmd
 --   }
 --   output.state.1
 --   {
 --   id=*
  --  state=%s
--	}]], state))
end   

-- Gets new state of button and sends it to 'chnge' function above.
function init()
  f = xap.Filter()
  f:add("xap-header","source","dbzoo.hal.CurrentCost:sensor.1")
  f:add("xap-header","class","xAPBSC.event")
  f:callback(chnge)
end 
