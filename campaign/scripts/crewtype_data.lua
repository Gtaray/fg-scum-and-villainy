function onInit()
	self.update();
end

function update()
	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
	local tFields = { "abilities", "upgrades", "contacts", "xptriggers" };
	WindowManager.callSafeControlsUpdate(self, tFields, bReadOnly);
end

function onDrop(x, y, draginfo)
	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
	if bReadOnly then
		return true;
	end

	local sDragType = draginfo.getType();
	if sDragType == "shortcut" then
		local sClass, sRecord = draginfo.getShortcutData();
		local node = DB.findNode(sRecord)
		if RecordDataManager.isRecordTypeDisplayClass("upgrade", sClass) then
			return self.addUpgrade(node);
		elseif RecordDataManager.isRecordTypeDisplayClass("ability", sClass) then
			return self.addAbility(node);
		end
	end
end

function addAbility(nodeAbility)
	if not nodeAbility then
		return;
	end

	local w = abilities.createWindow()
	w.shortcut.setValue("ability", DB.getPath(nodeAbility));
	return true;
end

function addUpgrade(nodeUpgrade)
	if not nodeUpgrade then
		return;
	end

	local w = upgrades.createWindow()
	w.shortcut.setValue("upgrade", DB.getPath(nodeUpgrade));
	return true;
end