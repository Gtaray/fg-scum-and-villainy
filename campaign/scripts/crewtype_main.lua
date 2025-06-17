function onInit()
	self.update();
end

function update()
	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
	local tFields = { "description" };
	WindowManager.callSafeControlsUpdate(self, tFields, bReadOnly);
end