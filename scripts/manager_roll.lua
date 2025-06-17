-------------------------------------------------------------------------------
--- PROMPTS
-------------------------------------------------------------------------------
function promptForPositionAndEffect(rActor, rRoll)
	local tData = {
		rActor = rActor,
		rRoll = rRoll,
		fnCallback = RollManager.processRollPrompt
	}
	DialogManager.openDialog("dialog_roll", tData);
end

function processRollPrompt(sResult, tData)
	if sResult == "ok" then
		ActionsManager.performAction(nil, tData.rActor, tData.rRoll);
	end
end

-------------------------------------------------------------------------------
--- BUILDING
-------------------------------------------------------------------------------
function buildRollDice(rActor, rRoll, nDice)
	if not rRoll.aDice then
		rRoll.aDice = {};
	end

	if nDice <= 0 then
		nDice = 2;
		rRoll.bTakeLowest = true;
	end
	for i = 1, nDice do
		table.insert(rRoll.aDice, "d6");
	end
end

-------------------------------------------------------------------------------
--- PROCESSING
-------------------------------------------------------------------------------
-- Adjusts the results of a standard roll to display it correctly
function processRoll(rSource, rTarget, rRoll)
	local fCompare = function(a,b) return a < b end;
	if rRoll.bTakeLowest then
		fCompare = function(a,b) return a > b end;
	end

	local nResult = 0;

	for i = 1, #(rRoll.aDice) do
        if rRoll.aDice[i].result == 6 then
            rRoll.aDice[i].type = "g" .. string.sub(rRoll.aDice[1].type, 2);
        elseif rRoll.aDice[i].result < 4 then
            rRoll.aDice[i].type = "r" .. string.sub(rRoll.aDice[1].type, 2);
        end

		if nResult == 0 or fCompare(nResult, rRoll.aDice[i].value) then
			nResult = rRoll.aDice[i].value;
		end

		rRoll.aDice[i].value = 0;
    end

	-- Set the first dice to have the result we actually want.
	rRoll.aDice[1].value = nResult;
	rRoll.nTotal = nResult;
end

-------------------------------------------------------------------------------
--- MESSAGING
-------------------------------------------------------------------------------
function buildActionMessage(rSource, rRoll)
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);
	
	return rMessage;
end