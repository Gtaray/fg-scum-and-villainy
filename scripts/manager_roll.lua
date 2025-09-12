function onInit()
	if Session.IsHost then
		RollManager.initializePositionAndEffectDbNodes();
	end
end

-------------------------------------------------------------------------------
--- POSITION AND EFFECT
-------------------------------------------------------------------------------
local _positionDbPath = "global.position";
local _effectDbPath = "global.effect";

function initializePositionAndEffectDbNodes()
	if not Session.IsHost then
		return;
	end

	RollManager.initializeGlobalNode(_positionDbPath, "string", "risky");
	RollManager.initializeGlobalNode(_effectDbPath, "string", "standard");
end

function initializeGlobalNode(sPath, sType, vInitialValue)
	local node = DB.findNode(sPath);
	if not node then
		node = DB.createNode(sPath, sType);
		DB.setValue(node, "", sType, vInitialValue);
	end

	if node then
		local globalnode = DB.getParent(node);
		DB.setPublic(node, true);
		DB.setPublic(globalnode, true);
	end
end

--
-- POSITION
--

function addPositionUpdateHandler(fHandler)
	DB.addHandler(_positionDbPath, "onUpdate", fHandler);
end

function getPosition()
	return DB.getValue(_positionDbPath, "risky");
end

function setPosition(sPosition)
	DB.setValue(_positionDbPath, "string", sPosition);
end

--
-- EFFECT
--

function addEffectUpdateHandler(fHandler)
	DB.addHandler(_effectDbPath, "onUpdate", fHandler);
end

function getEffect()
	return DB.getValue(_effectDbPath, "standard");
end

function setEffect(sEffect)
	DB.setValue(_effectDbPath, "string", sEffect);
end

--
-- DESKTOP PANEL
--

function registerPositionAndEffectPanel(w)
	self.resetPositionAndEffectPanel();
end

function resetPositionAndEffectPanel()
	RollManager.setPosition("risky");
	RollManager.setEffect("standard");
end

-------------------------------------------------------------------------------
--- DESKTOP MODIFIERS
-------------------------------------------------------------------------------
local _actionRollModWindow = nil;
function registerActionRollModWindow(w)
	_actionRollModWindow = w;
end

function getActionRollModPush(bRetain)
	return RollManager.getActionRollModWindowData("push", bRetain);
end

function getActionRollModBargain(bRetain)
	return RollManager.getActionRollModWindowData("bargain", bRetain);
end

function getActionRollModGambit(bRetain)
	return RollManager.getActionRollModWindowData("gambit", bRetain);
end

function getActionRollModAssist(bRetain)
	return RollManager.getActionRollModWindowData("assist", bRetain);
end

function getActionRollModInjury(bRetain)
	return RollManager.getActionRollModWindowData("injury", bRetain);
end

function getActionRollModWindowData(sControl, bRetain)
	if not _actionRollModWindow then
		return false;
	end

	local bValue = _actionRollModWindow[sControl].getValue() == 1;

	if not bRetain then
		RollManager.setActionRollModWindowData(sControl, false);
	end

	return bValue;
end

function setActionRollModWindowData(sControl, bToggle)
	if not _actionRollModWindow then
		return false;
	end

	local nVal = 0;
	if bToggle then 
		nVal = 1 
	end;

	_actionRollModWindow[sControl].setValue(nVal);
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