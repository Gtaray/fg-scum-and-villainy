function onInit()
    ActionsManager.registerModHandler("vice", modRoll);
    ActionsManager.registerResultHandler("vice", onRoll);
end

function performRoll(draginfo, rActor, rAction)
	local rRoll = ActionVice.getRoll(rActor, rAction);
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

function getRoll(rActor, rAction)
    local rRoll = {};
    rRoll.sType = "vice";

	rRoll.sAttribute, rRoll.nScore = CharManager.getViceAttribute(rActor);
	RollManager.buildRollDice(rActor, rRoll, rRoll.nScore);

	rRoll.sDesc = ActionVice.getRollLabel(rActor, rRoll);

    return rRoll;
end

function getRollLabel(rActor, rRoll)
	local attr = DataManager.getAttribute(rRoll.sAttribute);
    return string.format(
        "[VICE] %s", 
        Interface.getString(attr.sResource));
end

function modRoll(rSource, rTarget, rRoll)
end

function onRoll(rSource, rTarget, rRoll)
	RollManager.processRoll(rSource, rTarget, rRoll);

    local rMessage = RollManager.buildActionMessage(rSource, rRoll);
	--rMessage.text = ActionResistance.getFullRollText(rSource, rTarget, rRoll);

    Comm.deliverChatMessage(rMessage);
end

function getFullRollText(rSource, rTarget, rRoll)
	local nTotal = ActionsManager.total(rRoll);
	local sResult = string.format(Interface.getString("roll_text_resistance"), 6 - nTotal)
	return string.format("%s\n%s", rRoll.sDesc, sResult);
end