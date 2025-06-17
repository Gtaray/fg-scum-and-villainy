function onInit()
	self.update();
end

function update()
	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
	local tFields = { "cost", "description" };
	WindowManager.callSafeControlsUpdate(self, tFields, bReadOnly);

	-- Comboboxes don't have an "update" method to set its readonly status
	type.setComboBoxReadOnly(bReadOnly);
end