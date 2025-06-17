function onInit()
	self.populateDefaultXpTriggers();
end

function populateDefaultXpTriggers()
	-- Only populate once
	if #(CrewManager.getCrewXpTriggerNodes()) > 0 then
		return;
	end

	for nIndex, sTrigger in ipairs(DataManager.getDefaultCrewXpTriggers()) do
		CrewManager.createCrewXpTrigger(nIndex, sTrigger);
	end
end

-- Function override the core RPG onDrop for the main tab of the party sheet
function onDrop(x, y, draginfo)
	return false;
end