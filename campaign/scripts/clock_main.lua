function onInit()
	self.update();
end

function update()
	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
	local tFields = { "progress", "notes" };
	WindowManager.callSafeControlsUpdate(self, tFields, bReadOnly);

	-- Comboboxes don't have an "update" method to set its readonly status
	size_selector.setComboBoxReadOnly(bReadOnly);

	-- Clocks also don't set their readonly status via update method
	clock.setReadOnly(bReadOnly);
end