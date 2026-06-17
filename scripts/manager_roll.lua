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

function getActionRollModWindow()
	return _actionRollModWindow;
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

	rRoll.bTakeLowest = nDice <= 0;
	if nDice <= 0 then
		nDice = 2;
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
	local aDice = {}

    if rRoll.bTakeLowest then
        -- Get the subset of aDice that represent the first two dice to take the lowest from
        local _, nLowestIndex = getLowestDice({rRoll.aDice[1], rRoll.aDice[2]});
        table.insert(aDice, rRoll.aDice[nLowestIndex]);

        -- Record the number that was dropped so it can be put in chat
        if nLowestIndex == 1 then
            rRoll.aDroppedDie = rRoll.aDice[2]
        elseif nLowestIndex == 2 then
            rRoll.aDroppedDie = rRoll.aDice[1]
        end
    else
        aDice = rRoll.aDice;
    end

     -- Sort the dice table in descending order
    table.sort(aDice, function(a, b)
        return b.value < a.value
    end);

	local nNumberOfSixes = 0;
	for i = 1, #(aDice) do
        if aDice[i].result == 6 then
            aDice[i].type = "g" .. string.sub(aDice[1].type, 2);
            nNumberOfSixes = nNumberOfSixes + 1;

        elseif aDice[i].result < 4 then
            aDice[i].type = "r" .. string.sub(aDice[1].type, 2);

        end

        -- Only the first (highest) value is kept, everything else is zero
        if i >= 2 then
            aDice[i].value = 0;
        end
    end

	rRoll.bCritical = nNumberOfSixes >= 2;
	rRoll.aDice = aDice;
end

function getLowestDice(aDice)
    local nIndex = 0;
    local nLowestValue = 1000;
    for i = 1, #(aDice) do
        if aDice[i].value < nLowestValue then
            nIndex = i;
            nLowestValue = aDice[i].value;
        end
    end

    return nLowestValue, nIndex;
end

-------------------------------------------------------------------------------
--- MESSAGING
-------------------------------------------------------------------------------
function buildActionMessage(rSource, rRoll)
	local rMessage = ActionsManager.createActionMessage(rSource, rRoll);

	local s = rRoll.sDesc;

	if rRoll.sPosition and rRoll.sEffect then
		s = string.format("%s - %s / %s", 
			s, 
			Interface.getString(string.format("position_%s", rRoll.sPosition)), 
			Interface.getString(string.format("effect_%s", rRoll.sEffect)));
	end
    if rRoll.aDroppedDie then
        s = string.format("%s (Dropped %s)", s, rRoll.aDroppedDie.result)
    end
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

	if rRoll.sPosition == "desperate" then
		local tAttr = DataManager.getAttributeForAction(rRoll.sAction);
		if tAttr then
			local sAttr = StringManager.capitalize(Interface.getString(tAttr.sResource));

			s = string.format("%s\n%s", s, string.format(Interface.getString("roll_text_desperate_action"), sAttr));
		end
	end

	rMessage.text = s;
	
	return rMessage;
end