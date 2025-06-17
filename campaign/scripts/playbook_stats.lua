function onInit()
	self.update();
end

function onDrop(x, y, draginfo)
	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
	if bReadOnly then
		return true;
	end

	local sDragType = draginfo.getType();
	if sDragType == "shortcut" then
		local sClass, sRecord = draginfo.getShortcutData();
		if RecordDataManager.isRecordTypeDisplayClass("ability", sClass) then
			self.addAbility(DB.findNode(sRecord));
		elseif RecordDataManager.isRecordTypeDisplayClass("item", sClass) then
			self.addItem(DB.findNode(sRecord));
		end
	end
end

function update()
	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
	local tFields = { "tagline", "xptrigger", "actions", "abilities", "items", "contacts" };
	WindowManager.callSafeControlsUpdate(self, tFields, bReadOnly);
end

function addAbility(nodeAbility)
	if nodeAbility then
		local w = abilities.createWindow();
		DB.setValue(w.getDatabaseNode(), "shortcut", "windowreference", "ability", DB.getPath(nodeAbility));
	end
end

function addItem(nodeItem)
	if nodeItem then
		local w = items.createWindow();
		DB.setValue(w.getDatabaseNode(), "shortcut", "windowreference", "item", DB.getPath(nodeItem));
	end
end