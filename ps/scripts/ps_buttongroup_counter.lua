-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local fSetVarNumber;
local fOnClickRelease;
local fOnWheel;

local _bPlayerMouseEvent = false;

function onInit()
	fSetVarNumber = super.setVarNumber;
	super.setVarNumber = setVarNumber;

	fOnWheel = super.onWheel;
	super.onWheel = onWheel;

	fOnClickRelease = super.onClickRelease;
	super.onClickRelease = onClickRelease;

	if super and super.onInit then
		super.onInit()
	end

	registerMenuItem(Interface.getString("counter_menu_clear"), "erase", 4);
end

--
--	DATA SOURCE
--

function setVarNumber(sKey, n)
	if not Session.IsHost then
		if _bPlayerMouseEvent then
			local sPath = self.getVarNumberPath(sKey);
			if sPath ~= "" then
				CrewManager.sendPlayerUpdateOobMsg(sPath, "number", n)
			end
		end
		return
	end

	fSetVarNumber(sKey, n);
end

--
--	MOUSE BEHAVIORS
--

function onWheel(n)
	if Session.IsHost then
		return fOnWheel(n);
	end
	_bPlayerMouseEvent = true;
	local ret = fOnWheel(n);
	_bPlayerMouseEvent = false;

	return ret;
end

function onClickRelease(_, x, y)
	if Session.IsHost then
		return fOnClickRelease(_, x, y);
	end

	-- For players and players only, we mark that we had a mouse event, so that
	-- we can correctly send an OOB to update the value. ONLY do this on mouse events
	-- Otherwise when this thing loads it'll send the event an muck things up for
	-- the host.

	_bPlayerMouseEvent = true;
	local ret = fOnClickRelease(_, x, y);
	_bPlayerMouseEvent = false;

	return ret;
end

function onMenuSelection(selection)
	if selection == 4 then
		self.setCurrentValue(0);
	end
end