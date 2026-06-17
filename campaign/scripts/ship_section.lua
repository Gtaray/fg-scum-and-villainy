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

function addUpgrade(nodeUpgrade)
	if not nodeUpgrade then
		return false;
	end

	local w = upgrades.createWindow()
	w.shortcut.setValue("upgrade", DB.getPath(nodeUpgrade));

	return true;
end
