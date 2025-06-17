function onInit()
    ActionsManager.registerModHandler("fortune", modRoll);
    ActionsManager.registerResultHandler("fortune", onRoll);
end

function performRoll(draginfo, rActor, rAction)
	local rRoll = ActionFortune.getRoll(rActor, rAction);
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

function getRoll(rActor, rAction)
    local rRoll = {};
    rRoll.sType = "fortune";

	rRoll.nScore = rAction.nScore;
	rRoll.sDesc = ActionFortune.getRollLabel(rActor, rAction);
	
	if Session.IsHost and (OptionsManager.isOption("REVL", "off")) then
		rRoll.bSecret = true;
	end

	RollManager.buildRollDice(rActor, rRoll, rRoll.nScore);

    return rRoll;
end

function getRollLabel(rActor, rAction)
    return string.format(
        "[FORTUNE] %s", 
        rAction.sLabel);
end

function modRoll(rSource, rTarget, rRoll)
end

function onRoll(rSource, rTarget, rRoll)
	RollManager.processRoll(rSource, rTarget, rRoll);

    local rMessage = RollManager.buildActionMessage(rSource, rRoll);

    Comm.deliverChatMessage(rMessage);
end