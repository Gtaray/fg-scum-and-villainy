function onInit()
    ActionsManager.registerModHandler("resistance", modRoll);
    ActionsManager.registerResultHandler("resistance", onRoll);
end

function performRoll(draginfo, rActor, rAction)
	local rRoll = ActionResistance.getRoll(rActor, rAction);
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

function getRoll(rActor, rAction)
    local rRoll = {};
    rRoll.sType = "resistance";

	rRoll.nScore = CharManager.getResistanceScore(rActor, rAction.sAttribute);
	RollManager.buildRollDice(rActor, rRoll, rRoll.nScore);

    rRoll.sAttribute = rAction.sAttribute;
	rRoll.sDesc = ActionResistance.getRollLabel(rActor, rAction);

    return rRoll;
end

function getRollLabel(rActor, rAction)
	local attr = DataManager.getAttribute(rAction.sAttribute);
    return string.format(
        "[RESIST] %s", 
        Interface.getString(attr.sResource));
end

function modRoll(rSource, rTarget, rRoll)
end

function onRoll(rSource, rTarget, rRoll)
	RollManager.processRoll(rSource, rTarget, rRoll);

    local rMessage = RollManager.buildActionMessage(rSource, rRoll);
	rMessage.text = ActionResistance.getFullRollText(rSource, rTarget, rRoll);

    Comm.deliverChatMessage(rMessage);
end

function getFullRollText(rSource, rTarget, rRoll)
	local nTotal = ActionsManager.total(rRoll);
	local sResult = string.format(Interface.getString("roll_text_resistance"), 6 - nTotal)
	return string.format("%s\n%s", rRoll.sDesc, sResult);
end