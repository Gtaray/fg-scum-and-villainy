function onInit()
	self.updateHeader()
	self.update()
end

function update()
	local w = UtilityManager.getTopWindow(self);
	local bReadOnly = WindowManager.getReadOnlyState(w.getDatabaseNode());

	local tFields = { "rating", "maxrating", "upgrades" };
	WindowManager.callSafeControlsUpdate(self, tFields, bReadOnly);
end

function setData(tSectionData)
	name.setValue(tSectionData.sSection);
	self.updateHeader();
end

function updateHeader()
	local sSectionName = name.getValue();
	local tData = DataManager.getShipSection(sSectionName)
	if tData then
		header.setValue(Interface.getString(tData.sResource));
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