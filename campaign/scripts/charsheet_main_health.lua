function onInit()
	local charnode = getDatabaseNode();
	DB.addHandler(DB.getPath(charnode, "attributes.*.actions.*.rating"), "onUpdate", onActionRatingUpdated)
	DB.addHandler(DB.getPath(charnode, "health.vice.bonusdice"), "onUpdate", onActionRatingUpdated)

	self.onActionRatingUpdated();
end

function onClose()
	local charnode = getDatabaseNode();
	DB.removeHandler(DB.getPath(charnode, "attributes.*.actions.*.rating"), "onUpdate", onActionRatingUpdated)
	DB.removeHandler(DB.getPath(charnode, "health.vice.bonusdice"), "onUpdate", onActionRatingUpdated)
end

function onActionRatingUpdated()
	local sAttr, nScore = CharManager.getViceAttribute(getDatabaseNode())
	local tAttr = DataManager.getAttribute(sAttr);

	if not tAttr then
		button_vice.setTooltipText("????");
	else
		button_vice.setTooltipText(string.format("%s (%sd6)", Interface.getString(tAttr.sResource), nScore));
	end
end

function performViceRoll(draginfo)
	local rActor = ActorManager.resolveActor(UtilityManager.getTopWindow(self).getDatabaseNode());

	-- The performRoll() method will get all the relevant attribute data for the actor
	ActionVice.performRoll(draginfo, rActor, {})
end