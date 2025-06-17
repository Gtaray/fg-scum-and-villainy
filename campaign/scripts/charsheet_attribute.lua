function onInit()
	self.updateHeader();
end

function setData(tAttrData)
	attribute.setValue(tAttrData.sAttribute);
	self.updateHeader();
	actions.populate();
end

function updateHeader()
	local sAttr = attribute.getValue();
	local tData = DataManager.getAttribute(sAttr)
	if tData then
		header.setValue(Interface.getString(tData.sResource));
	end
end

function performResistanceRoll(draginfo)
	local attrNode = getDatabaseNode();
	local rActor = ActorManager.resolveActor(UtilityManager.getTopWindow(self).getDatabaseNode());
	local rAction = {
		sAttribute = DB.getValue(attrNode, "attribute", "");
		nBonusDice = DB.getValue(attrNode, "resistance.bonusdice", 0);
	}
	ActionResistance.performRoll(draginfo, rActor, rAction)
end
