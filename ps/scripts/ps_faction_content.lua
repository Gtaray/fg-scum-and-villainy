-------------------------------------------------------------------------------
--- UPDATING DISPLAY
-------------------------------------------------------------------------------
function update()
	local node = self.getFactionNode();
	description.setValue(DB.getValue(node, "description", ""));
	
	local nClockSize = DB.getValue(node, "goal.clocksize", 4);
	local nProgress = DB.getValue(node, "goal.progress", 0);
	goal.subwindow.updateClock(nClockSize, nProgress);
	goal.subwindow.tier_label.setValue(self.getTierNumerals());
	goal.subwindow.description.setValue(DB.getValue(node, "goal.summary", ""));
end

-------------------------------------------------------------------------------
--- HELPERS
-------------------------------------------------------------------------------
function getFactionNode()
	local _, sRecord = DB.getValue(getDatabaseNode(), "link", "", "")
	return DB.findNode(sRecord);
end

local _tTierNumerals = {
	[1] = "I",
	[2] = "II",
	[3] = "III",
	[4] = "IV",
	[5] = "V",
}
function getTierNumerals()
	local nTier = DB.getValue(self.getFactionNode(), "tier", 1)
	if not _tTierNumerals[nTier] then
		return "???"
	end
	return _tTierNumerals[nTier];
end