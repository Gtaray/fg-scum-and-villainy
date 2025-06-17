function onInit()
	self.update();
end

function update()
	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
	local tFields = { "tier", "description", "situation", "goal", "turf", "npcs", "assets", "quirks", "allies", "enemies", "npclist" };
	WindowManager.callSafeControlsUpdate(self, tFields, bReadOnly);
end

function onDrop(x, y, draginfo)
	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
	if bReadOnly then
		return true;
	end

	if draginfo.isType("shortcut") then
		local sClass, sRecord = draginfo.getShortcutData();
		local node = DB.findNode(sRecord)
		if RecordDataManager.isRecordTypeDisplayClass("npc", sClass) then
			return self.addNPC(node)
		end
	end
end

function addNPC(nodeNPC)
	local w = npclist.createWindow()
	local node = w.getDatabaseNode()
	DB.setValue(node, "shortcut", "windowreference", "npc", DB.getPath(nodeNPC))
	return true
end