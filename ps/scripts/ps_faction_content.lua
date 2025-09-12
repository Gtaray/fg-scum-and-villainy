-------------------------------------------------------------------------------
--- UPDATING DISPLAY
-------------------------------------------------------------------------------
function update()
	local node = self.getFactionNode();

	goal.setVisible(DB.getValue(node, "goal.visible", 0) == 1);

	if goal.isVisible() then
		local nClockSize = DB.getValue(node, "goal.size", 4);
		local nProgress = DB.getValue(node, "goal.progress", 0);

		goal.subwindow.updateClock(nClockSize, nProgress);
		goal.subwindow.description.setValue(DB.getValue(node, "goal.name", ""));
	end
end

-------------------------------------------------------------------------------
--- HELPERS
-------------------------------------------------------------------------------
function getFactionNode()
	local _, sRecord = DB.getValue(getDatabaseNode(), "link", "", "")
	return DB.findNode(sRecord);
end