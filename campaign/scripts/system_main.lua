function onInit()
	self.update();
end

function update()
	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
	local tFields = { "description", "notables", "locations" };
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
		if RecordDataManager.isRecordTypeDisplayClass("location", sClass) then
			local node = DB.findNode(sRecord)
			if node then
				local w = locations.createWindow();
				DB.setValue(w.getDatabaseNode(), "shortcut", "windowreference", sClass, sRecord)
			end
		end
	end
end