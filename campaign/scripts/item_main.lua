function onInit()
	self.update();
end

function update()
	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
	local tFields = { "load", "sub_nonid", "quality", "notes" };
	WindowManager.callSafeControlsUpdate(self, tFields, bReadOnly);
end