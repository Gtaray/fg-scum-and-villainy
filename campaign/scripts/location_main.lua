function onInit()
	self.update();
end

function update()
	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
	local tFields = { "description", "scene", "effect", "npcs" };
	WindowManager.callSafeControlsUpdate(self, tFields, bReadOnly);

	wealth.setReadOnly(bReadOnly);
	crime.setReadOnly(bReadOnly);
	tech.setReadOnly(bReadOnly);
	weird.setReadOnly(bReadOnly);
end