function onInit()
	self.update();
end

function update()
	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
	local tFields = { "tier", "description", "situation", "goal", "turf", "assets", "quirks", "npclist", "factionlist", "rumorlist" };
	WindowManager.callSafeControlsUpdate(self, tFields, bReadOnly);
	
	self.onLockModeChanged(bReadOnly);
end

function onLockModeChanged(bReadOnly)
	local tFields = { "npcs_iadd", "npcs_iedit", "rumors_iadd", "rumors_iedit" };
	WindowManager.callSafeControlsSetLockMode(self, tFields, bReadOnly);
end

function onDrop(x, y, draginfo)
	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
	if bReadOnly then
		return true;
	end

	if draginfo.isType("shortcut") then
		local sClass, sRecord = draginfo.getShortcutData();
		local node = DB.findNode(sRecord)
		if RecordDataManager.isRecordTypeDisplayClass("faction", sClass) then
			return self.addFaction(node);
		elseif RecordDataManager.isRecordTypeDisplayClass("npc", sClass) then
			return self.addNPC(node)
		end
	end
end

function addFaction(nodeFaction)
	local w = factionlist.createWindow();
	local node = w.getDatabaseNode();
	DB.setValue(node, "shortcut", "windowreference", "faction", DB.getPath(nodeFaction));
	return true;
end

function addNPC(nodeNPC)
	local w = npclist.createWindow();
	local node = w.getDatabaseNode();
	DB.setValue(node, "shortcut", "windowreference", "npc", DB.getPath(nodeNPC));
	return true;
end