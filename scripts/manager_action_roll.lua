local fActionRoll;

function onInit()
    ActionsManager.registerModHandler("action", modRoll);
    ActionsManager.registerResultHandler("action", onRoll);
end

function performRoll(draginfo, rActor, rAction)
	local rRoll = ActionRoll.getRoll(rActor, rAction);
	ActionsManager.performAction(draginfo, rActor, rRoll);
end

function getRoll(rActor, rAction)
    local rRoll = {};
    rRoll.sType = "action";

	rRoll.nScore = CharManager.getActionScore(rActor, rAction.sAction);
	RollManager.buildRollDice(rActor, rRoll, rRoll.nScore);

    rRoll.sAction = rAction.sAction;
	rRoll.sDesc = ActionRoll.getRollLabel(rActor, rAction);

	rRoll.sPosition = RollManager.getPosition();
	rRoll.sEffect = RollManager.getEffect();
	rRoll.bPush = RollManager.getActionRollModPush();
	rRoll.bBargain = RollManager.getActionRollModBargain();
	rRoll.bAssist = RollManager.getActionRollModAssist();
	rRoll.bGambit = RollManager.getActionRollModGambit();
	rRoll.bInjured = RollManager.getActionRollModInjury();

    return rRoll;
end

function getRollLabel(rActor, rAction)
	local action = DataManager.getAction(rAction.sAction);
    return string.format(
        "[ACTION] %s", 
        Interface.getString(action.sResource));
end

function modRoll(rSource, rTarget, rRoll)
	local nDiceAdjust = 0;
	if rRoll.bPush then
		nDiceAdjust = nDiceAdjust + 1;
	end
	if rRoll.bBargain then
		nDiceAdjust = nDiceAdjust + 1;
	end
	if rRoll.bAssist then
		nDiceAdjust = nDiceAdjust + 1;
	end
	if rRoll.bGambit then
		nDiceAdjust = nDiceAdjust + 1;
	end
	if rRoll.bInjured then
		nDiceAdjust = nDiceAdjust - 1;
	end

	-- The easiest way to modify the dice pool is to reset aDice and build it again
	if nDiceAdjust ~= 0 then
		-- If the roll previously had 0 dice (roll 2, take the lowest)
		-- Then we set the base dice back to 2. This effectively makes the nDiceAdjust
		-- act as the regular dice amount
		local nBaseDice = #(rRoll.aDice);
		if rRoll.bTakeLowest then
			nBaseDice = 0
		end

		rRoll.aDice = {};
		RollManager.buildRollDice(rActor, rRoll, nBaseDice + nDiceAdjust);
	end
end

function onRoll(rSource, rTarget, rRoll)
	RollManager.processRoll(rSource, rTarget, rRoll);

    local rMessage = RollManager.buildActionMessage(rSource, rRoll);

    Comm.deliverChatMessage(rMessage);
end