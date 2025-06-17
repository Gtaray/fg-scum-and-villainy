
function onInit()
    ActionsManager.registerModHandler("engagement", modRoll);
    ActionsManager.registerResultHandler("engagement", onRoll);
end

function performRoll(draginfo, rAction)
	local rRoll = ActionEngagement.getRoll(rAction);
	ActionsManager.performAction(draginfo, nil, rRoll);
end

function getRoll(rAction)
    local rRoll = {};
    rRoll.sType = "engagement";
	rRoll.sDesc = ActionEngagement.getRollLabel(rAction);
	
	if Session.IsHost and (OptionsManager.isOption("REVL", "off")) then
		rRoll.bSecret = true;
	end

	RollManager.buildRollDice(nil, rRoll, rAction.nDice);

    return rRoll;
end

function getRollLabel(rAction)
    return string.format(
        "[ENGAGEMENT] %s", 
        rAction.sLabel);
end

function modRoll(rSource, rTarget, rRoll)
end

function onRoll(rSource, rTarget, rRoll)
	RollManager.processRoll(rSource, rTarget, rRoll);

    local rMessage = RollManager.buildActionMessage(rSource, rRoll);

    Comm.deliverChatMessage(rMessage);

	-- Write the result back to the Job Sheet / Combat Tracker
	JobManager.setEngagementRollResult(rRoll.nTotal);

	-- TODO: OOB that sets the engagement roll result on the party sheet
end