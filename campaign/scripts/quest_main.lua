function onInit()
	self.update();
end

function update()
	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
	local tFields = { "payout", "notes", "factionlist" };
	WindowManager.callSafeControlsUpdate(self, tFields, bReadOnly);
end

function onDrop(x, y, draginfo)
	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
	if bReadOnly then
		return true;
	end

	if draginfo.isType("shortcut") then
		local sClass, sRecord = draginfo.getShortcutData();
		local node = DB.findNode(sRecord);
		if RecordDataManager.isRecordTypeDisplayClass("system", sClass) then
			return self.addSystem(node);
		elseif RecordDataManager.isRecordTypeDisplayClass("faction", sClass) then
			return self.addFaction(node);
		end
	end
end

function addSystem(nodeSystem)
	systemlink.setValue("system", DB.getPath(nodeSystem));
end

function addFaction(nodeFaction)
	if not nodeFaction then
		return;
	end

	local w = factionlist.createWindow();
	w.shortcut.setValue("faction", DB.getPath(nodeFaction));
	return true;
end