function onInit()
	self.updateHeader()
	self.update()
end

function update()
	local w = UtilityManager.getTopWindow(self);	
	local bReadOnly = WindowManager.getReadOnlyState(w.getDatabaseNode());

	local tFields = { "rating" };
	WindowManager.callSafeControlsUpdate(self, tFields, bReadOnly);
end

function setData(tActionData)
	action.setValue(tActionData.sAction);
	self.updateHeader();
end

function updateHeader()
	local sActionName = action.getValue();
	local tData = DataManager.getAction(sActionName)
	if tData then
		action_label.setValue(Interface.getString(tData.sResource));
	end
end