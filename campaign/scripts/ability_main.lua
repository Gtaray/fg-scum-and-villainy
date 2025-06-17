function onInit()
	self.update();
end

function update()
	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
	local tFields = { "type", "cost", "description" };
	WindowManager.callSafeControlsUpdate(self, tFields, bReadOnly);
end