function onInit()
	WindowTabManager.populate(self);
end

function onDrop(x, y, draginfo)
	local crewnode = getDatabaseNode();

	if draginfo.isType("shortcut") then
		local sClass, sRecord = draginfo.getShortcutData();
		local node = DB.findNode(sRecord)
		if RecordDataManager.isRecordTypeDisplayClass("upgrade", sClass) then
			CrewManager.addSectionUpgrade(crewnode, node);
			return true;
		end
	end
end