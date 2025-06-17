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
	Comm.deliverChatMessage(rMessage);
end