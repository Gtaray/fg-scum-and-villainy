-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local fSetVarNumber;

function onInit()
	fSetVarNumber = super.setVarNumber;
	super.setVarNumber = setVarNumber;

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
		local sPath = self.getVarNumberPath(sKey);
		if sPath ~= "" then
			CrewManager.sendPlayerUpdateOobMsg(sPath, "number", n)
		end
		return
	end

	fSetVarNumber(sKey, n);
end

--
--	MOUSE BEHAVIORS
--

function onMenuSelection(selection)
	if selection == 4 then
		self.setCurrentValue(0);
	end
end