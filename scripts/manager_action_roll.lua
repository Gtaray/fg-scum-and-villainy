function onInit()
    ActionsManager.registerModHandler("action", modRoll);
    ActionsManager.registerResultHandler("action", onRoll);
end

function performRoll(draginfo, rActor, rAction)
	local rRoll = ActionRoll.getRoll(rActor, rAction);
	RollManager.promptForPositionAndEffect(rActor, rRoll);
end

function getRoll(rActor, rAction)
    local rRoll = {};
    rRoll.sType = "action";

	rRoll.nScore = CharManager.getActionScore(rActor, rAction.sAction);
	RollManager.buildRollDice(rActor, rRoll, rRoll.nScore);

    rRoll.sAction = rAction.sAction;
	rRoll.sDesc = ActionRoll.getRollLabel(rActor, rAction);

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
		local nBaseDice = #(rRoll.aDice);

		rRoll.aDice = {};
		RollManager.buildRollDice(rActor, rRoll, nBaseDice + nDiceAdjust);
	end
end

function onRoll(rSource, rTarget, rRoll)
	RollManager.processRoll(rSource, rTarget, rRoll);

    local rMessage = RollManager.buildActionMessage(rSource, rRoll);
	rMessage.text = ActionRoll.getFullRollText(rSource, rTarget, rRoll);

    Comm.deliverChatMessage(rMessage);
end

function getFullRollText(rSource, rTarget, rRoll)
	local s = string.format("%s - %s / %s", rRoll.sDesc, rRoll.sPosition, rRoll.sEffect);
	if rRoll.bPush then
		s = string.format("%s\n%s", s, Interface.getString("roll_text_push_yourself"));
	end
	if rRoll.bBargain then
		s = string.format("%s\n%s", s, Interface.getString("roll_text_devils_bargain"));
	end
	if rRoll.bAssist then
		s = string.format("%s\n%s", s, Interface.getString("roll_text_assisted"));
	end
	if rRoll.bGambit then
		s = string.format("%s\n%s", s, Interface.getString("roll_text_spent_gambit"));
	end
	if rRoll.bInjured then
		s = string.format("%s\n%s", s, Interface.getString("roll_text_injured"));
	end
	if rRoll.sPosition == "Desperate" then
		local tAttr = DataManager.getAttributeForAction(rRoll.sAction);
		if tAttr then
			local sAttr = StringManager.capitalize(Interface.getString(tAttr.sResource));

			s = string.format("%s\n%s", s, string.format(Interface.getString("roll_text_desperate_action"), sAttr));
		end
	end
	return s;
end