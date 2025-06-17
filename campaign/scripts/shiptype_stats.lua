function onInit()
	self.update();
end

function update()
	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
	local tFields = { "crewrating", "size", "gambits", "cred", "debt", "sections", "upgrades" };
	WindowManager.callSafeControlsUpdate(self, tFields, bReadOnly);

	-- Comboboxes don't have an "update" method to set its readonly status
	size.setComboBoxReadOnly(bReadOnly);
end

function onDrop(x, y, draginfo)
	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
	if bReadOnly then
		return true;
	end

	local sDragType = draginfo.getType();
	if sDragType == "shortcut" then
		local sClass, sRecord = draginfo.getShortcutData();
		if RecordDataManager.isRecordTypeDisplayClass("upgrade", sClass) then
			local node = DB.findNode(sRecord)
			if node then
				local sType = DB.getValue(node, "type", ""):lower()
				local w = self.getSectionSubwindow(sType)
				if w then 
					return w.addUpgrade(node);
				else
					return self.addToUpgradesList(node);
				end
			end
		end
	end
end

function getSectionSubwindow(sSection)
	sSection = sSection:lower();
	if DataManager.hasShipSection(sSection) then
		for _, w in ipairs(sections.getWindows()) do
			if w.name.getValue():lower() == sSection then
				return w;
			end
		end
	end

	return nil;
end

function addToUpgradesList(nodeUpgrade)
	local w = upgrades.createWindow();
	w.shortcut.setValue("upgrade", DB.getPath(nodeUpgrade));
	return true;
end