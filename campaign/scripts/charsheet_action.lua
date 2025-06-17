function onInit()
	self.updateHeader();
end

function setData(tData)
	action.setValue(tData.sAction);
	self.updateHeader();
end

function updateHeader()
	local sAction = action.getValue();
	local tData = DataManager.getAction(sAction)
	if tData then
		label.setValue(Interface.getString(tData.sResource));
	end
end

function performActionRoll(draginfo)
	local attrNode = getDatabaseNode();
	local rActor = ActorManager.resolveActor(UtilityManager.getTopWindow(self).getDatabaseNode());
	local rAction = {
		sAction = DB.getValue(attrNode, "action", "");
		nBonusDice = DB.getValue(attrNode, "bonusdice", 0);
	}
	ActionRoll.performRoll(draginfo, rActor, rAction)
end
