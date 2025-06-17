function onInit()
	self.updateHeader();
end

function setData(tSectionData)
	name.setValue(tSectionData.sSection);
	self.updateHeader();
end

function updateHeader()
	local sName = self.getSectionNameDisplayText();
	if sName then
		header.setValue(sName);
	end
end

function getSectionName()
	return name.getValue():lower();
end

function getSectionNameDisplayText()
	local sSectionName = self.getSectionName();
	local tData = DataManager.getShipSection(sSectionName)
	if tData then
		return Interface.getString(tData.sResource);
	end
end

function performFortuneRoll(draginfo)
	local node = getDatabaseNode();
	local w = UtilityManager.getTopWindow(self)
	local sCrewName = DB.getValue(w.getDatabaseNode(), "crew.name", "");

	local rAction = {
		nScore = DB.getValue(node, "rating", 0),
		sLabel = string.format("%s - %s", sCrewName, self.getSectionNameDisplayText())
	}

	ActionFortune.performRoll(draginfo, nil, rAction);
	return true;
end