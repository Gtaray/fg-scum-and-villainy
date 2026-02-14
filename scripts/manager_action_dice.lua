function onInit()
	ActionsManager.registerResultHandler("dice", onRoll);
end

function onRoll(rSource, rTarget, rRoll)
	local bOnlyD6s = true;
	for _, aDie in ipairs(rRoll.aDice) do
		if aDie.type ~= "d6" then
			bOnlyD6s = false;
			break;
		end
	end
	
	if bOnlyD6s then
		RollManager.processRoll(rSource, rTarget, rRoll);
	end

	local rMessage = RollManager.buildActionMessage(rSource, rRoll);

	if rRoll.aDroppedDie then
        rMessage.text = string.format("Dropped %s", rRoll.aDroppedDie.result)
    end

	Comm.deliverChatMessage(rMessage);
end