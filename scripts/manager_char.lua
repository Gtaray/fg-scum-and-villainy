function addPlaybook(nodeChar, nodePlaybook)
	if not nodeChar then
		return;
	end
	if not nodePlaybook then
		return;
	end

	DB.setValue(nodeChar, "playbook.link", "windowreference", "playbook", DB.getPath(nodePlaybook));
	DB.setValue(nodeChar, "playbook.name", "string", DB.getValue(nodePlaybook, "name", ""));
	DB.setValue(nodeChar, "playbook.tagline", "string", DB.getValue(nodePlaybook, "tagline", ""));

	-- Actions
	for _, action in ipairs(DB.getChildList(nodePlaybook, "actions")) do
		local sAction = DB.getValue(action, "action", "");
		local nRating = DB.getValue(action, "rating", 0);

		if sAction ~= "" then
			CharManager.setActionScore(nodeChar, sAction, nRating);
		end
	end

	-- Abilities
	for _, ability in ipairs(DB.getChildList(nodePlaybook, "abilities")) do
		local bUnlocked = DB.getValue(ability, "given", 0) == 1;
		local _, sRecord = DB.getValue(ability, "shortcut", "", "");
		local node = DB.findNode(sRecord)
		CharManager.addAbility(nodeChar, node, bUnlocked);
	end

	-- XP Trigger
	CharManager.setXpTrigger(nodeChar, DB.getValue(nodePlaybook, "xptrigger"));

	-- Contacts
	for _, contact in ipairs(DB.getChildList(nodePlaybook, "contacts")) do
		CharManager.addContact(nodeChar, DB.getValue(contact, "contact", ""));
	end

	-- Items
	for _, item in ipairs(DB.getChildList(nodePlaybook, "items")) do
		local _, sRecord = DB.getValue(item, "shortcut", "", "");
		local node = DB.findNode(sRecord)
		CharManager.addPlaybookItem(nodeChar, node);
	end
end

function addHeritage(rActor, nodeHeritage)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

	if not nodeChar then
		return;
	end

	DB.setValue(nodeChar, "heritage.name", "string", DB.getValue(nodeHeritage, "name", ""))
	DB.setValue(nodeChar, "heritage.text", "formattedtext", DB.getValue(nodeHeritage, "text", ""))
end

function addBackground(rActor, nodeBackground)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

	if not nodeChar then
		return;
	end

	DB.setValue(nodeChar, "background.name", "string", DB.getValue(nodeBackground, "name", ""))
	DB.setValue(nodeChar, "background.text", "formattedtext", DB.getValue(nodeBackground, "text", ""))
end

-------------------------------------------------------------------------------
--- ACTIONS AND ATTRIBUTE SCORES
-------------------------------------------------------------------------------
function getAttributeNode(rActor, sAttribute)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

	if not nodeChar then
		return;
	end

	for _, node in ipairs(DB.getChildList(nodeChar, "attributes")) do
		if DB.getValue(node, "attribute", ""):lower() == sAttribute:lower() then
			return node;
		end
	end
end
function getAttributeScore(rActor, sAttribute)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

    if not sAttribute then
        return 0;
    end
    if not nodeChar then
        return 0;
    end

	local attrNode = CharManager.getAttributeNode(nodeChar, sAttribute);
    if not attrNode then
        return 0;
    end

	local nAttribute = 0;
    for _, action in ipairs(DB.getChildList(attrNode, "actions")) do
		if DB.getValue(action, "rating", 0) > 0 then
			nAttribute = nAttribute + 1;
		end
	end

    return nAttribute;
end

function getResistanceScore(rActor, sAttribute)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

	local nScore = CharManager.getAttributeScore(nodeChar, sAttribute);
	local attrNode = CharManager.getAttributeNode(nodeChar, sAttribute);
    if attrNode then
		nScore = nScore + DB.getValue(attrNode, "resistance.bonusdice", 0);
    end

	return nScore;
end

function getActionNode(rActor, sAction)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

	if not nodeChar then
		return;
	end

	local tAction = DataManager.getAction(sAction);
	if not tAction then
		return;
	end

	local attrNode = CharManager.getAttributeNode(nodeChar, tAction.sAttribute);
	if not attrNode then
		return;
	end

	for _, node in ipairs(DB.getChildList(attrNode, "actions")) do
		if DB.getValue(node, "action", ""):lower() == tAction.sAction:lower() then
			return node;
		end
	end
end
function getActionScore(rActor, sAction)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

    if not sAction then
        return 0;
    end
    if not nodeChar then
        return 0;
    end
    if not DataManager.hasAction(sAction) then
        return 0;
    end

	local actionNode = CharManager.getActionNode(nodeChar, sAction);
	if actionNode then
		local nRating = DB.getValue(actionNode, "rating", 0);
		local nBonus = DB.getValue(actionNode, "bonusdice", 0);
		return nRating + nBonus;
	end
end
function setActionScore(rActor, sAction, nValue)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

	if not nodeChar then
		return;
	end

	if not DataManager.hasAction(sAction) then
		return;
	end

	local actionNode = CharManager.getActionNode(nodeChar, sAction);
	if actionNode then
		DB.setValue(actionNode, "rating", "number", nValue);
	end
end

-------------------------------------------------------------------------------
--- STRESS
-------------------------------------------------------------------------------
function getStressMax(rActor)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

    return DB.getValue(nodeChar, "health.stress.max", 0);
end

function modifyStressMax(rActor, nDelta)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

    local nNewValue = CharManager.getStressMax(nodeChar) + nDelta;
    CharManager.setStressMax(nodeChar, nNewValue);
    return nNewValue;
end

function setStressMax(rActor)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

    DB.setValue(nodeChar, "health.stress.max", "number", nValue);
end

function getStress(rActor)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

    return DB.getValue(nodeChar, "health.stress.current", 0);
end

function modifyStress(rActor, nDelta)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

    local nNewValue = CharManager.getStress(nodeChar) + nDelta;
    CharManager.setStress(nodeChar, nNewValue);
    return nNewValue;
end

function setStress(rActor, nValue)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

    DB.setValue(nodeChar, "health.stress.current", "number", nValue);
end

-------------------------------------------------------------------------------
--- HEALING CLOCK
-------------------------------------------------------------------------------
function getRecoveryClock(rActor)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

    return DB.getValue(nodeChar, "health.recovery.progress", 0);
end
function setRecoveryClock(rActor, nValue)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

    DB.setValue(nodeChar, "health.recovery.progress", "number", nValue);
end

function getRecoveryClockSize(rActor)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

    return DB.getValue(nodeChar, "health.recovery.clocksize", 0);
end
function setHealingClockSize(rActor, nValue)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

    DB.setValue(nodeChar, "health.recovery.clocksize", "number", nValue);
end

-------------------------------------------------------------------------------
--- HARM
-------------------------------------------------------------------------------
function hasLesserHarm(rActor)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

    local lesser1 = DB.getValue(nodeChar, "health.harm.lesser1", "");
    local lesser2 = DB.getValue(nodeChar, "health.harm.lesser2", "");

    return lesser1 ~= "" or lesser2 ~= "";
end

function hasModerateHarm(rActor)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

    local moderate1 = DB.getValue(nodeChar, "health.harm.moderate1", "");
    local moderate2 = DB.getValue(nodeChar, "health.harm.moderate2", "");

    return moderate1 ~= "" or moderate2 ~= "";
end

function hasSevereHarm(rActor)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

    return DB.getValue(nodeChar, "health.harm.severe", "") ~= ""
end

-------------------------------------------------------------------------------
--- TRAUMA
-------------------------------------------------------------------------------
function getTraumaMax(rActor)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

    return DB.getValue(nodeChar, "health.trauma.max", 0);
end

function modifyTraumaMax(rActor, nDelta)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

    local nNewValue = CharManager.getTraumaMax(nodeChar) + nDelta;
    CharManager.setTraumaMax(nodeChar, nNewValue);
    return nNewValue;
end

function setTraumaMax(rActor)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

    DB.setValue(nodeChar, "health.trauma.max", "number", nValue);
end

function getTrauma(rActor)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

    return DB.getValue(nodeChar, "health.trauma.current", 0);
end

function modifyTrauma(rActor, nDelta)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

    local nNewValue = CharManager.getTrauma(nodeChar) + nDelta;
    CharManager.setTrauma(nodeChar, nNewValue);
    return nNewValue;
end

function setTrauma(rActor, nValue)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

    DB.setValue(nodeChar, "health.trauma.current", "number", nValue);
end

-------------------------------------------------------------------------------
--- GEAR AND LOAD
-------------------------------------------------------------------------------
function getCurrentCarriedLoad(rActor)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

	local nCarriedLoad = 0;
	for _, itemNode in ipairs(CharManager.getInventoryNodes(nodeChar)) do
		local nLoad = DB.getValue(itemNode, "load", 1);
		local nEquipped = DB.getValue(itemNode, "equipped", 0);

		-- If the equipped value is greater than the load value
		-- And equipped is greater than 0, then we add it to the total load
		-- This handles both items that cost zero load (but have a single equip pip)
		-- and items that cost multiple load
		if nEquipped > 0 and nEquipped >= nLoad then
			nCarriedLoad = nCarriedLoad + nLoad;
		end
	end

	return nCarriedLoad;
end

function getCurrentMaxLoad(rActor)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

	if DB.getValue(nodeChar, "inventory.load.light", 0) > 0 then
		return DB.getValue(nodeChar, "inventory.load.lightamount", 3);
	elseif DB.getValue(nodeChar, "inventory.load.normal", 0) > 0 then
		return DB.getValue(nodeChar, "inventory.load.normalamount", 5);
	elseif DB.getValue(nodeChar, "inventory.load.heavy", 0) > 0 then
		return DB.getValue(nodeChar, "inventory.load.heavyamount", 6);
	else
		return 0;
	end
end

function addGenericItem(rActor, nodeItem)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

	local listnode = CharManager.getInventoryNode(nodeChar);
	if not listnode then
		return;
	end

	local node = DB.createChildAndCopy(listnode, nodeItem)
	DB.setValue(node, "type", "string", "Generic")
	return node;
end

function addPlaybookItem(rActor, nodeItem)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

	local node = CharManager.addGenericItem(nodeChar, nodeItem);
	if not node then
		return;
	end

	DB.setValue(node, "type", "string", "Playbook");
	return node;
end

function getInventoryNode(rActor)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

	if not nodeChar then
		return;
	end

	return DB.createChild(nodeChar, "inventory.gear");
end

function getInventoryNodes(rActor)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

    return DB.getChildList(nodeChar, "inventory.gear");
end

-------------------------------------------------------------------------------
--- ABILITIES
-------------------------------------------------------------------------------
function getAbilityNodes(rActor)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

	
    return DB.getChildList(nodeChar, "abilitylist");
end

function getAbilityListNode(rActor)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

	if not nodeChar then
		return; 
	end

	return DB.createChild(nodeChar, "abilities");
end

function addAbility(rActor, nodeAbility, bUnlocked)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

	if not nodeAbility then
		return;
	end
	local listnode = CharManager.getAbilityListNode(nodeChar);
	if not listnode then
		return;
	end

	bUnlocked = bUnlocked or false;

	local node = DB.createChildAndCopy(listnode, nodeAbility);
	if bUnlocked then
		local nCost = DB.getValue(nodeAbility, "cost", 1);
		DB.setValue(node, "paid", "number", nCost);
	end
	
	return node;
end

-------------------------------------------------------------------------------
--- CONTACTS
-------------------------------------------------------------------------------
function getContactNodes(rActor)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

    return DB.getChildList(nodeChar, "contacts");
end

function addContact(rActor, sContact)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

	if not nodeChar then
		return;
	end

	local listnode = DB.createChild(nodeChar, "contacts");
	if not listnode then
		return;
	end

	local node = DB.createChild(listnode);
	if node then
		DB.setValue(node, "name", "string", sContact)
	end
	return node;
end

-------------------------------------------------------------------------------
--- XP AND ADVANCEMENTS
-------------------------------------------------------------------------------
function getAttributeXp(rActor, sAttribute)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

    if not sAttribute then
        return 0;
    end
    if not nodeChar then
        return 0;
    end
    if not DataManager.hasAttribute(sAttribute) then
        return 0;
    end

    local sPath = string.format("attributes.%.xp", sAttribute:lower())
    return DB.getValue(nodeChar, sPath, 0);
end

function getPlaybookXp(rActor)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

	if not nodeChar then
		return;
	end
	return DB.getValue(nodeChar, "playbook.xp", 0);
end

function setXpTrigger(rActor, sTrigger)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

	if not nodeChar then
		return;
	end
	if not sTrigger then
		return;
	end

	DB.setValue(nodeChar, "playbook.xptrigger", "string", sTrigger);
end

-------------------------------------------------------------------------------
--- PLAYBOOK
-------------------------------------------------------------------------------
function getPlaybook(rActor)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

    local sClass, sRecord = DB.getValue(nodeChar, "playbook.link", "", "");
    return DB.findNode(sRecord);
end

-------------------------------------------------------------------------------
--- CLOCKS
-------------------------------------------------------------------------------
function getClocksNode(rActor)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

	if not nodeChar then
		return;
	end
	return DB.createChild(nodeChar, "clocks")
end

function addClock(rActor, nodeClock)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

	local listnode = CharManager.getClocksNode(nodeChar);
	if not listnode then
		return;
	end

	return DB.createChildAndCopy(listnode, nodeClock);
end

-------------------------------------------------------------------------------
--- CREW
-------------------------------------------------------------------------------
function getCrew(rActor)
	local nodeChar;
	if type(rActor) == "databasenode" then
		nodeChar = rActor;
	else
		nodeChar = ActorManager.getCreatureNode(rActor);
	end

    local sClass, sRecord = DB.getValue(nodeChar, "crew.link", "", "");
    return DB.findNode(sRecord);
end
