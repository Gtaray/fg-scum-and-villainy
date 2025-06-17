-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--
-- This is exclusively to handle data transactions on the party sheet (i.e. the crew sheet)
-- Script modifies the data in manager_ps.lua, 
-- since the party sheet is being re-purposed as the crew sheet

OOB_MSGTYPE_PARTYSHEET_DROP = "partysheetdrop"
OOB_MSGTYPE_PARTYSHEET_UPDATE = "partysheetupdate"
OOB_MSGTYPE_PARTYSHEET_CREATECLOCK = "partysheetcreateclock"
OOB_MSGTYPE_PARTYSHEET_DELETECLOCK = "partysheetdeleteclock"
OOB_MSGTYPE_PARTYSHEET_CREATEJOB = "partysheetcreatejob"
OOB_MSGTYPE_PARTYSHEET_DELETEJOB = "partysheetdeletejob"

local _psNode;

function onInit()
	OOBManager.registerOOBMsgHandler(CrewManager.OOB_MSGTYPE_PARTYSHEET_DROP, CrewManager.handlePlayerDroppedOobMsg);
	OOBManager.registerOOBMsgHandler(CrewManager.OOB_MSGTYPE_PARTYSHEET_UPDATE, CrewManager.handlePlayerUpdateOobMsg);
	OOBManager.registerOOBMsgHandler(CrewManager.OOB_MSGTYPE_PARTYSHEET_CREATECLOCK, CrewManager.handlePlayerCreateClock);
	OOBManager.registerOOBMsgHandler(CrewManager.OOB_MSGTYPE_PARTYSHEET_DELETECLOCK, CrewManager.handlePlayerDeleteClock);
	OOBManager.registerOOBMsgHandler(CrewManager.OOB_MSGTYPE_PARTYSHEET_CREATEJOB, CrewManager.handlePlayerCreateJob);
	OOBManager.registerOOBMsgHandler(CrewManager.OOB_MSGTYPE_PARTYSHEET_DELETEJOB, CrewManager.handlePlayerDeleteJob);

	WindowTabManager.unregisterTab("partysheet_host", "main");
	WindowTabManager.unregisterTab("partysheet_host", "inventory");
	WindowTabManager.unregisterTab("partysheet_host", "order");
	WindowTabManager.registerTab("partysheet_host", { sName = "main", sTabRes = "ps_tab_main", sClass = "ps_main" });
	WindowTabManager.registerTab("partysheet_host", { sName = "upgrades", sTabRes = "ps_tab_upgrades", sClass = "ps_upgrades" });
	WindowTabManager.registerTab("partysheet_host", { sName = "abilities", sTabRes = "ps_tab_abilities", sClass = "ps_abilities" });
	WindowTabManager.registerTab("partysheet_host", { sName = "factions", sTabRes = "ps_tab_factions", sClass = "ps_factions" });
	WindowTabManager.registerTab("partysheet_host", { sName = "heat", sTabRes = "ps_tab_heat", sClass = "ps_heat" });
	WindowTabManager.registerTab("partysheet_host", { sName = "clocks", sTabRes = "ps_tab_clocks", sClass = "ps_clocks" });
	WindowTabManager.registerTab("partysheet_host", { sName = "jobs", sTabRes = "ps_tab_jobs", sClass = "ps_jobs" });

	WindowTabManager.unregisterTab("partysheet_client", "main");
	WindowTabManager.unregisterTab("partysheet_client", "inventory");
	WindowTabManager.unregisterTab("partysheet_client", "order");
	WindowTabManager.registerTab("partysheet_client", { sName = "main", sTabRes = "ps_tab_main", sClass = "ps_main" });
	WindowTabManager.registerTab("partysheet_client", { sName = "upgrades", sTabRes = "ps_tab_upgrades", sClass = "ps_upgrades" });
	WindowTabManager.registerTab("partysheet_client", { sName = "abilities", sTabRes = "ps_tab_abilities", sClass = "ps_abilities" });
	WindowTabManager.registerTab("partysheet_client", { sName = "factions", sTabRes = "ps_tab_factions", sClass = "ps_factions" });
	WindowTabManager.registerTab("partysheet_client", { sName = "heat", sTabRes = "ps_tab_heat", sClass = "ps_heat" });
	WindowTabManager.registerTab("partysheet_client", { sName = "clocks", sTabRes = "ps_tab_clocks", sClass = "ps_clocks" });
	WindowTabManager.registerTab("partysheet_client", { sName = "jobs", sTabRes = "ps_tab_jobs", sClass = "ps_jobs" });

	_psNode = DB.findNode("partysheet");

	if Session.IsHost then
		DB.addHandler(DB.getPath(_psNode, "sections.*.upgrades.*.paid"), "onUpdate", onUpgradePaidFor)
		DB.addHandler(DB.getPath(_psNode, "sections.*.upgrades"), "onChildDeleted", onUpgradeDeleted)
		DB.addHandler(DB.getPath(_psNode, "crew.rating"), "onUpdate", onRatingChanged)
		DB.addHandler(DB.getPath(_psNode, "sections.*.rating"), "onUpdate", onRatingChanged)
		DB.addHandler(DB.getPath(_psNode, "sections.*.maxrating"), "onUpdate", onSystemMaxRatingChanged)

		self.updateUpkeep();
		self.updateAllSectionRatings();
		self.initializeSectionUpgrades();
	end
end

function onClose()
	if Session.IsHost then
		DB.removeHandler(DB.getPath(_psNode, "sections.*.upgrades.*.paid"), "onUpdate", onUpgradePaidFor)
		DB.removeHandler(DB.getPath(_psNode, "sections.*.upgrades"), "onChildDeleted", onUpgradeDeleted)
		DB.removeHandler(DB.getPath(_psNode, "crew.rating"), "onUpdate", onRatingChanged)
		DB.removeHandler(DB.getPath(_psNode, "sections.*.rating"), "onUpdate", onRatingChanged)
		DB.addHandler(DB.getPath(_psNode, "sections.*.maxrating"), "onUpdate", onSystemMaxRatingChanged)
	end
end

function onRatingChanged()
	if Session.IsHost then
		CrewManager.updateUpkeep();
	end
end

function onSystemMaxRatingChanged(nodeRating)
	if Session.IsHost then
		local sSection = DB.getValue(nodeRating, "..name");
		CrewManager.updateEmptySectionUpgrades(sSection);
	end
end

function onUpgradePaidFor()
	if Session.IsHost then
		CrewManager.updateAllSectionRatings();
	end
end

function onUpgradeDeleted(node)
	if Session.IsHost then
		CrewManager.updateAllSectionRatings();

		local sSection = DB.getValue(node, "..name");
		CrewManager.updateEmptySectionUpgrades(sSection);
	end
end

function updateAllSectionRatings()
	for _, tData in ipairs(DataManager.getShipSections()) do
		CrewManager.updateSectionRating(tData.sSection);
	end
end

function updateUpkeep()
	if Session.IsHost then
		CrewManager.setUpkeep(CrewManager.calculateUpkeep());
	end
end

--  Initializes all sections with empty actions for their max rating
function initializeSectionUpgrades()
	for _, tData in ipairs(DataManager.getShipSections()) do
		CrewManager.updateEmptySectionUpgrades(tData.sSection);
	end
end

function updateEmptySectionUpgrades(sSection)
	local nMaxRating = CrewManager.getSectionMax(sSection);
	local nUpgradeCount = CrewManager.getSectionUpgradeCount(sSection);

	if nMaxRating == nUpgradeCount then
		return;
	end

	while nUpgradeCount < nMaxRating do
		CrewManager.addEmptySectionUpgrade(sSection);
		nUpgradeCount = CrewManager.getSectionUpgradeCount(sSection);
	end

	while nUpgradeCount > nMaxRating do
		local nodes = CrewManager.getSectionUpgradeNodes(sSection, true)
		DB.deleteNode(nodes[#nodes]); -- Delete the last node in the list
		nUpgradeCount = CrewManager.getSectionUpgradeCount(sSection);
	end
end

-------------------------------------------------------------------------------
-- OOB HANDLING FOR PLAYERS INTERACTING WITH THE PARTY SHEET
-------------------------------------------------------------------------------
function sendPlayerDroppedOobMsg(sClass, nodeDrop)
	if not Session.IsHost then
		local msg = {
			type = CrewManager.OOB_MSGTYPE_PARTYSHEET_DROP,
			sClass = sClass,
			sPath = DB.getPath(nodeDrop)
		}
		Comm.deliverOOBMessage(msg)
	end
end

function handlePlayerDroppedOobMsg(msgOOB)
	if not Session.IsHost then
		return;
	end

	CrewManager.handleDropNode(msgOOB.sClass, DB.findNode(msgOOB.sPath))
end

function sendPlayerUpdateOobMsg(sPath, sDataType, vValue)
	if (sPath or "") == "" then
		return;
	end
	if (sDataType or "") == "" then
		return;
	end
	if vValue == nil then
		return;
	end

	local msg = {
		type = CrewManager.OOB_MSGTYPE_PARTYSHEET_UPDATE,
		sPath = sPath,
		sDataType = sDataType,
		vValue = vValue
	};

	Comm.deliverOOBMessage(msg);
end

function handlePlayerUpdateOobMsg(msg)
	if not Session.IsHost then
		return;
	end

	if (msg.sPath or "") == "" then
		return;
	end
	if (msg.sDataType or "") == "" then
		return;
	end
	if msg.vValue == nil then
		return;
	end

	if sDataType == "number" then
		msg.vValue = tonumber(msg.vValue);
	end

	DB.setValue(msg.sPath, msg.sDataType, msg.vValue);
end

function sendPlayerCreateClockOobMsg()
	local msg = {
		type = CrewManager.OOB_MSGTYPE_PARTYSHEET_CREATECLOCK
	}
	Comm.deliverOOBMessage(msg);
end

function handlePlayerCreateClock(msgOOB)
	if not Session.IsHost then
		return;
	end

	CrewManager.addCrewClock()
end

function sendPlayerDeleteClockOobMsg(clockNode)
	local msg = {
		type = CrewManager.OOB_MSGTYPE_PARTYSHEET_DELETECLOCK,
		sClockNode = DB.getPath(clockNode)
	}
	Comm.deliverOOBMessage(msg);
end

function handlePlayerDeleteClock(msgOOB)
	if not Session.IsHost then
		return;
	end

	CrewManager.deleteCrewClock(msgOOB.sClockNode)
end

function sendPlayerCreateJobOobMsg()
	local msg = {
		type = CrewManager.OOB_MSGTYPE_PARTYSHEET_CREATEJOB
	}
	Comm.deliverOOBMessage(msg);
end

function handlePlayerCreateJob(msgOOB)
	if not Session.IsHost then
		return;
	end

	CrewManager.addEmptyJob()
end

function sendPlayerDeleteJobOobMsg(jobNode)
	local msg = {
		type = CrewManager.OOB_MSGTYPE_PARTYSHEET_DELETEJOB,
		sJobNode = DB.getPath(jobNode)
	}
	Comm.deliverOOBMessage(msg);
end

function handlePlayerDeleteJob(msgOOB)
	if not Session.IsHost then
		return;
	end

	CrewManager.deleteJob(msgOOB.sJobNode)
end

-------------------------------------------------------------------------------
-- ON DROP
-------------------------------------------------------------------------------
function handleDrop(draginfo)
	if draginfo.isType("shortcut") then
		local sClass, sRecord = draginfo.getShortcutData();
		local node = DB.findNode(sRecord)

		-- Only GM should be able to drop items? Maybe trigger an OOB
		if not Session.IsHost then
			CrewManager.sendPlayerDroppedOobMsg(sClass, node);
		else
			CrewManager.handleDropNode(sClass, node);
		end
	end
end

function handleDropNode(sClass, node)
	if RecordDataManager.isRecordTypeDisplayClass("shiptype", sClass) then
		return CrewManager.addShipType(node);
	elseif RecordDataManager.isRecordTypeDisplayClass("crewtype", sClass) then
		return CrewManager.addCrewType(node);
	elseif RecordDataManager.isRecordTypeDisplayClass("upgrade", sClass) then
		return CrewManager.addUpgrade(node);
	elseif RecordDataManager.isRecordTypeDisplayClass("ability", sClass) then
		return CrewManager.addAbility(node);
	elseif RecordDataManager.isRecordTypeDisplayClass("faction", sClass) then
		return CrewManager.addFaction(node);
	elseif RecordDataManager.isRecordTypeDisplayClass("system", sClass) then
		return CrewManager.addSystem(node);
	elseif RecordDataManager.isRecordTypeDisplayClass("clock", sClass) then
		ClockManager.handleClockDroppedOnRecord(_psNode, node);
	elseif RecordDataManager.isRecordTypeDisplayClass("quest", sClass) then
		return CrewManager.addJob(node);
	end
end

function addShipType(nodeShipType)
	if not nodeShipType then
		return;
	end

	CrewManager.setShipClassNode(nodeShipType);
	CrewManager.setShipClassName(DB.getValue(nodeShipType, "name", ""));
	CrewManager.setShipSize(DB.getValue(nodeShipType, "size", ""));

	CrewManager.setCrewRating(DB.getValue(nodeShipType, "crewrating", 0));

	CrewManager.setGambits(DB.getValue(nodeShipType, "gambits", 0));
	CrewManager.setDefaultGambits(DB.getValue(nodeShipType, "gambits", 0));

	CrewManager.setCred(DB.getValue(nodeShipType, "cred", 0))
	CrewManager.setDebt(DB.getValue(nodeShipType, "debt", 0))

	for _, sectionnode in ipairs(DB.getChildList(nodeShipType, "sections")) do
		local sSection = DB.getValue(sectionnode, "name", ""):lower();
		CrewManager.setSectionMax(sSection, DB.getValue(sectionnode, "maxrating", 0));
		CrewManager.setSectionRating(sSection, DB.getValue(sectionnode, "rating", 0));

		DB.deleteChildren(CrewManager.getSectionNode(sSection), "upgrades");
		for _, upgradenode in ipairs(DB.getChildList(sectionnode, "upgrades")) do
			local _, sRecord = DB.getValue(upgradenode, "shortcut", "", "");
			local node = DB.findNode(sRecord)
			local bUnlocked = DB.getValue(upgradenode, "given", 0) == 1;
			CrewManager.addUpgrade(node, bUnlocked);
		end
	end

	DB.deleteChildren(_psNode, "upgrades.auxiliary");
	DB.deleteChildren(_psNode, "upgrades.shipgear");
	DB.deleteChildren(_psNode, "upgrades.crewgear");
	DB.deleteChildren(_psNode, "upgrades.training");
	for _, upgradenode in ipairs(DB.getChildList(nodeShipType, "upgrades")) do
		local _, sRecord = DB.getValue(upgradenode, "shortcut", "", "");
		local node = DB.findNode(sRecord)
		local bUnlocked = DB.getValue(upgradenode, "given", 0) == 1;
		CrewManager.addUpgrade(node, bUnlocked);
	end
end

function addCrewType(nodeCrewType)
	if not nodeCrewType then
		return;
	end

	DB.deleteChildren(_psNode, "upgrades.specialabilities");
	for _, abilitynode in ipairs(DB.getChildList(nodeCrewType, "abilities")) do
		local _, sRecord = DB.getValue(abilitynode, "shortcut", "", "");
		local node = DB.findNode(sRecord);
		local bUnlocked = DB.getValue(abilitynode, "given", 0) == 1;
		CrewManager.addAbility(node, bUnlocked);
	end

	DB.deleteChildren(_psNode, "upgrades.crewupgrades");
	for _, upgradenode in ipairs(DB.getChildList(nodeCrewType, "upgrades")) do
		local _, sRecord = DB.getValue(upgradenode, "shortcut", "", "");
		local node = DB.findNode(sRecord);
		local bUnlocked = DB.getValue(upgradenode, "given", 0) == 1;
		CrewManager.addUpgrade(node, bUnlocked);
	end

	DB.deleteChildren(_psNode, "crew.contacts");
	for _, contactnode in ipairs(DB.getChildList(nodeCrewType, "contacts")) do
		CrewManager.addContact(DB.getValue(contactnode, "contact", ""));
	end

	for _, xptriggernode in ipairs(DB.getChildList(nodeCrewType, "xptriggers")) do
		CrewManager.createCrewXpTrigger(1, DB.getValue(xptriggernode, "xptrigger", ""));
	end
end

function addUpgrade(upgradeNode, bUnlocked)
	if not upgradeNode then
		return;
	end

	local sType = DB.getValue(upgradeNode, "type", ""):lower();
	
	-- If this upgrade is for a ship section, add it there and return
	if DataManager.hasShipSection(sType) then
		return CrewManager.addSectionUpgrade(upgradeNode, bUnlocked);
	elseif sType == "auxiliary" then
		return CrewManager.addAuxiliaryUpgrade(upgradeNode, bUnlocked);
	elseif sType == "training" then
		return CrewManager.addTrainingUpgrade(upgradeNode, bUnlocked);
	elseif sType == "ship gear" then
		return CrewManager.addShipGearUpgrade(upgradeNode, bUnlocked);
	elseif sType == "crew gear" then
		return CrewManager.addCrewGearUpgrade(upgradeNode, bUnlocked);
	elseif sType == "ship/crew upgrade" then
		return CrewManager.addCrewUpgrade(upgradeNode, bUnlocked);
	end

	return false;
end

function addAbility(abilityNode)
	if not abilityNode then
		return;
	end
	return CrewManager.addSpecialAbility(abilityNode);
end

function addFaction(nodeFaction)
	if not nodeFaction then
		return;
	end

	DB.setPublic(nodeFaction, true);

	local listnode = DB.createChild(_psNode, "factions");
	if not listnode then
		return;
	end

	local newnode = DB.createChild(listnode);
	if not newnode then
		return;
	end

	DB.setValue(newnode, "link", "windowreference", "faction", DB.getPath(nodeFaction));
end

function addSystem(nodeSystem)
	if not nodeSystem then
		return;
	end

	DB.setPublic(nodeSystem, true);

	local listnode = DB.createChild(_psNode, "systems");
	if not listnode then
		return;
	end

	local newnode = DB.createChild(listnode);
	if not newnode then
		return;
	end

	DB.setValue(newnode, "link", "windowreference", "system", DB.getPath(nodeSystem));
end

-------------------------------------------------------------------------------
-- BASIC INFO
-------------------------------------------------------------------------------
function getCrewName()
    return DB.getValue(_psNode, "crew.name", "");
end

function getCrewReputation()
    return DB.getValue(_psNode, "crew.reputation", "");
end

function getCrewRating()
    return DB.getValue(_psNode, "crew.rating", 0);
end
function setCrewRating(nRating)
	DB.setValue(_psNode, "crew.rating", "number", nRating);
end

function getContactNodes()
	DB.getValue(_psNode, "crew.contacts")
end
function addContact(sContact)
	local listnode = DB.createChild(_psNode, "crew.contacts");
	if not listnode then
		return;
	end

	local node = DB.createChild(listnode);
	DB.setValue(node, "contact", "string", sContact);
end

-------------------------------------------------------------------------------
-- SHIP CLASS
-------------------------------------------------------------------------------
function getShipClassNode()
    local _, sRecord = DB.getValue(_psNode, "ship.link", "", "");
    return DB.findNode(sRecord);
end
function setShipClassNode(nodeShip)
    DB.setValue(_psNode, "ship.link", "ship", DB.getPath(nodeShip))
end

function getShipSize()
    return DB.getValue(_psNode, "ship.size", "");
end
function setShipSize(sValue)
    DB.setValue(_psNode, "ship.size", "string", sValue);
end

function getShipClassName()
    return DB.getValue(_psNode, "ship.class", "");
end
function setShipClassName(sName)
    DB.setValue(_psNode, "ship.class", "string", sName)
end

function getShipLook()
    return DB.getValue(_psNode, "ship.look", "");
end
function setShipLook(sLook)
    DB.setValue(_psNode, "ship.look", "string", sLook)
end

-------------------------------------------------------------------------------
-- SHIP SYSTEMS
-------------------------------------------------------------------------------
function getSectionNode(sSection)
	if not DataManager.hasShipSection(sSection) then
        return;
    end

	sSection = sSection:lower();
	for _, sectionnode in ipairs(DB.getChildList(_psNode, "sections")) do
		local sName = DB.getValue(sectionnode, "name", ""):lower()
		if sName == sSection then
			return sectionnode;
		end
	end
end

function getSectionRating(sSection)
	local node = CrewManager.getSectionNode(sSection);
	if not node then
		return 0;
	end

    return DB.getValue(node, "rating", 0);
end
function setSectionRating(sSection, nValue)
    local node = CrewManager.getSectionNode(sSection);
	if not node then
		return;
	end

	nValue = math.max(nValue, 0);
	local nMax = CrewManager.getSectionMax(sSection)
    DB.setValue(node, "rating", "number", math.min(nValue, nMax));
end
function updateSectionRating(sSection)
	local node = CrewManager.getSectionNode(sSection);
	if not node then
		return 0;
	end

	local nRating = 0;
	for _, upgrade in ipairs(DB.getChildList(node, "upgrades")) do
		local nCost = DB.getValue(upgrade, "cost", 1);
		local nPaid = DB.getValue(upgrade, "paid", 0);
		if nPaid >= nCost then
			nRating = nRating + 1;
		end
	end
	CrewManager.setSectionRating(sSection, nRating);
end

function getSectionMax(sSection)
    local node = CrewManager.getSectionNode(sSection);
	if not node then
		return 0;
	end
    
    return DB.getValue(node, "maxrating", 0);
end
function setSectionMax(sSection, nValue)
    local node = CrewManager.getSectionNode(sSection);
	if not node then
		return 0;
	end
    
    DB.setValue(node, "maxrating", "number", nValue);
end

-------------------------------------------------------------------------------
-- SHIP SYSTEM UPGRADES
-------------------------------------------------------------------------------
function getSectionUpgradeNodes(sSection, bIncludeEmpty)
	local node = CrewManager.getSectionNode(sSection);
	if not node then
		return {};
	end

	local finalnodes = {}
	for _, upgrade in ipairs(DB.getChildList(node, "upgrades")) do
		local sName = DB.getValue(upgrade, "name");
		if (sName or "") ~= "" or bIncludeEmpty then
			table.insert(finalnodes, upgrade);
		end
	end

	return finalnodes;
end
function getSectionUpgradeCount(sSection)
	local node = CrewManager.getSectionNode(sSection);
	if not node then
		return 0;
	end
	return DB.getChildCount(node, "upgrades");
end

function addSectionUpgrade(nodeUpgrade, bUnlocked)
	local sSection = DB.getValue(nodeUpgrade, "type", "");
	local sectionnode = CrewManager.getSectionNode(sSection);
	local sPath = string.format("sections.%s.upgrades", DB.getName(sectionnode));

	return CrewManager.addUpgradeOrAbilityToList(nodeUpgrade, sPath, bUnlocked);
end

function addEmptySectionUpgrade(sSection)
	local node = CrewManager.getSectionNode(sSection);
	if not node then
		return;
	end

	local listnode = DB.createChild(node, "upgrades");
	return DB.createChild(listnode)
end
-------------------------------------------------------------------------------
-- XP AND ADVANCEMENT
-------------------------------------------------------------------------------
function getCrewXp()
    return DB.getValue(_psNode, "advancement.xp", 0);
end
function setCrewXp(nValue)
    DB.setValue(_psNode, "advancement.xp", "number", nValue);
end

function getCrewXpTriggerNodes()
    return DB.getChildList(_psNode, "advancement.xptriggers")
end
function createCrewXpTrigger(nOrder, sTrigger)
	if not Session.IsHost then
		return
	end
	
	local nodes = CrewManager.getCrewXpTriggerNodes();

	-- Update the order for all existing nodes
	-- This is technically a very poor way of handling this, 
	-- but the trigger list will be very small (1-5 entries) so I'm not too worried
	if nOrder <= #nodes then
		for nIndex, node in ipairs(nodes) do
			-- If the node's order is equal to or more than the one we're adding
			-- we bump it up by one. This effectively does an insert
			if nIndex >= nOrder then
				DB.setValue(node, "order", "number", nIndex + 1)
			end
		end
	end

	local listnode = DB.createChild(_psNode, "advancement.xptriggers");
	local newnode = DB.createChild(listnode);
	DB.setValue(newnode, "description", "string", sTrigger);
	DB.setValue(newnode, "order", "number", nOrder);
end

-------------------------------------------------------------------------------
-- CRED
-------------------------------------------------------------------------------
function getCred()
    return DB.getValue(_psNode, "cred.current", 0);
end
function setCred(nValue)
	DB.setValue(_psNode, "cred.current", "number", nValue);
end
function getCredMax()
    return DB.getValue(_psNode, "cred.max", 0);
end
function setCredMax(nValue)
	DB.setValue(_psNode, "cred.max", "number", nValue);
end

function getDebt()
    return DB.getValue(_psNode, "debt.current", 0);
end
function setDebt(nValue)
	DB.setValue(_psNode, "debt.current", "number", nValue);
end
function getDebtMax()
    return DB.getValue(_psNode, "debt.max", 0);
end
function setDebtMax(nValue)
	DB.setValue(_psNode, "debt.current", "number", nValue);
end

-------------------------------------------------------------------------------
-- UPKEEP
-------------------------------------------------------------------------------
function getUpkeep()
    return DB.getValue(_psNode, "upkeep.total", 0);
end
function setUpkeep(nValue)
    DB.setValue(_psNode, "upkeep.total", "number", nValue);
end

function getUpkeepSkips()
    return DB.getValue(_psNode, "upkeep.skips", 0);
end
function setUpkeepSkips(nValue)
    DB.setValue(_psNode, "upkeep.skips", "number", nValue);
end

function calculateUpkeep()
    local nRating = CrewManager.getCrewRating();
    for _, tData in pairs(DataManager.getShipSections()) do
        nRating = nRating + CrewManager.getSectionRating(tData.sSection)
    end

    return math.floor(nRating / 4)
end

-------------------------------------------------------------------------------
-- GAMBITS
-------------------------------------------------------------------------------
function getGambits()
    return DB.getValue(_psNode, "gambits.current", 0);
end
function setGambits(nValue)
    DB.setValue(_psNode, "gambits.current", "number", nValue);
end

function getDefaultGambits()
    return DB.getValue(_psNode, "gambits.default", 0);
end
function setDefaultGambits(nValue)
    DB.setValue(_psNode, "gambits.default", "number", nValue);
end

function getMaximumGambits()
    return DB.getValue(_psNode, "gambits.max", 0);
end
function setMaximumGambits(nValue)
    DB.setValue(_psNode, "gambits.max", "number", nValue);
end

-------------------------------------------------------------------------------
-- ABILITIES / UPGRADES
-------------------------------------------------------------------------------
function getSpecialAbilityNodes()
    return DB.getChildList(_psNode, "upgrades.specialabilities")
end
function addSpecialAbility(abilityNode, bUnlocked)
	return CrewManager.addUpgradeOrAbilityToList(abilityNode, "upgrades.specialabilities", bUnlocked)
end

function getCrewUpgradeNodes()
    return DB.getChildList(_psNode, "upgrades.crewupgrades")
end
function addCrewUpgrade(upgradeNode, bUnlocked)
	return CrewManager.addUpgradeOrAbilityToList(upgradeNode, "upgrades.crewupgrades", bUnlocked)
end

function getAuxiliaryUpgradeNodes()
    return DB.getChildList(_psNode, "upgrades.auxiliary");
end
function addAuxiliaryUpgrade(upgradeNode, bUnlocked)
	return CrewManager.addUpgradeOrAbilityToList(upgradeNode, "upgrades.auxiliary", bUnlocked);
end

function getShipGearUpgradeNodes()
    return DB.getChildList(_psNode, "upgrades.shipgear");
end
function addShipGearUpgrade(upgradeNode, bUnlocked)
	return CrewManager.addUpgradeOrAbilityToList(upgradeNode, "upgrades.shipgear", bUnlocked);
end

function getCrewGearUpgradeNodes()
    return DB.getChildList(_psNode, "upgrades.crewgear");
end
function addCrewGearUpgrade(upgradeNode, bUnlocked)
	return CrewManager.addUpgradeOrAbilityToList(upgradeNode, "upgrades.crewgear", bUnlocked);
end

function getTrainingUpgradeNodes()
    return DB.getChildList(_psNode, "upgrades.training");
end
function addTrainingUpgrade(upgradeNode, bUnlocked)
	return CrewManager.addUpgradeOrAbilityToList(upgradeNode, "upgrades.training", bUnlocked);
end

function addUpgradeOrAbilityToList(nodeUpgrade, sList, bUnlocked)
	local listnode = DB.createChild(_psNode, sList);
	if not listnode then
		return false;
	end

	-- Default to false
	bUnlocked = bUnlocked or false;

	-- Go through the list of upgrades and see if one matches the dropped value
	local sUpgradeName = DB.getValue(nodeUpgrade, "name", "");
	local matchnode;
	local emptynode;
	for _, node in ipairs(DB.getChildList(listnode)) do
		local sName = DB.getValue(node, "name", "");
		if not emptynode and (sName or "") == "" then
			emptynode = node;
		elseif (sName or "") ~= "" and sUpgradeName == sName then
			matchnode = node
			break;
		end
	end

	-- If a match was found, don't add the upgrade again
	-- instead just mark it as fully paid for.
	if matchnode then
		emptynode = matchnode;
		bUnlocked = true;
	end

	-- If we didn't find an empty node to fill, then we create a new node
	if not emptynode then
		emptynode = DB.createChild(listnode)
	end
	DB.copyNode(nodeUpgrade, emptynode)

	if bUnlocked then
		local nCost = DB.getValue(nodeUpgrade, "cost", 1);
		DB.setValue(emptynode, "paid", "number", nCost);
	end

	return true, emptynode;
end

-------------------------------------------------------------------------------
-- Factions
-------------------------------------------------------------------------------
function onFactionNotesEditedByPlayer(sResult, tData)
	if sResult ~= "ok" then
		return;
	end

	CrewManager.sendPlayerUpdateOobMsg(tData.sDbPath, "string", tData.sText)
end

-------------------------------------------------------------------------------
-- Clocks
-------------------------------------------------------------------------------
function addCrewClock()
	local listnode = DB.getChild(_psNode, "clocks");
	if not listnode then
		return;
	end

	local clockNode = DB.createChild(listnode);
	return clockNode;
end

function deleteCrewClock(clockNode)
	if not clockNode then
		return;
	end

	DB.deleteNode(clockNode);
end

function onClockEditedByPlayer(sResult, tData)
	if sResult ~= "ok" then
		return;
	end

	CrewManager.sendPlayerUpdateOobMsg(tData.sDbPath, "string", tData.sText)
end

-------------------------------------------------------------------------------
-- Systems / Heat
-------------------------------------------------------------------------------
function getSystem(nodeSystem)
	if not nodeSystem then
		return;
	end

	local listnode = DB.getChild(_psNode, "systems");
	if not listnode then
		return;
	end

	local sSystemNode = DB.getPath(nodeSystem);
	for _, node in ipairs(listnode.getChildren()) do
		local _, sLinkedSystem = DB.getValue(node, "link", "", "")
		if sLinkedSystem == sSystemNode then
			return node
		end
	end
end

-------------------------------------------------------------------------------
-- Jobs
-------------------------------------------------------------------------------
function getJobListNode()
	return DB.createChild(_psNode, "jobs");
end

function addEmptyJob()
	if not Session.IsHost then
		return;
	end

	local tJob = {
		sName = "New Job",
		sDescription = "",
		sNotes = "",
		sGmNotes = "",
		nPayout = 0,
		nodeSystem = nil,
		tFactions = {},
		sEngagementPlan = "",
		sEngagementResult = ""
	}

	CrewManager.addJobFromJobSheet(tJob);
end

function addJob(nodeJob)
	if not Session.IsHost then
		return;
	end

	local _, sRecord = DB.getValue(nodeJob, "systemlink", "", "");
	local nodeSystem = DB.findNode(sRecord);

	local tJob = {
		sName = DB.getValue(nodeJob, "name", ""),
		sDescription = DB.getValue(nodeJob, "description", ""),
		sNotes = "",
		sGmNotes = DB.getValue(nodeJob, "gmnotes", ""),
		nPayout = DB.getValue(nodeJob, "payout", 0),
		nodeSystem = nodeSystem,
		tFactions = {},
		sEngagementPlan = "",
		sEngagementResult = "",
	}

	for _, node in ipairs(DB.getChildren(nodeJob, "factions")) do
		local _, sPath = DB.getValue(node, "shortcut", "", "");
		local tFaction = {
			nStanding = DB.getValue(node, "standing", 0),
			nodeFaction = DB.findNode(sPath)
		}
		table.insert(tJob.tFactions, tFaction);
	end

	CrewManager.addJobFromJobSheet(tJob);
end

function addJobFromJobSheet(tJob)
	if not Session.IsHost then
		return;
	end

	local listnode = CrewManager.getJobListNode();
	if not listnode then
		return;
	end

	local jobnode = DB.createChild(listnode);
	DB.setValue(jobnode, "name", "string", tJob.sName);
	DB.setValue(jobnode, "description", "formattedtext", tJob.sDescription);
	DB.setValue(jobnode, "notes", "formattedtext", tJob.sNotes);
	DB.setValue(jobnode, "gmnotes", "formattedtext", tJob.sGmNotes);
	DB.setValue(jobnode, "payout", "number", tJob.nPayout);
	if tJob.nodeSystem then
		DB.setValue(jobnode, "systemlink", "windowreference", "system", DB.getPath(tJob.nodeSystem));
	end
	DB.setValue(jobnode, "engagementplan", "string", tJob.sEngagementPlan);
	DB.setValue(jobnode, "engagementresult", "string", tJob.sEngagementResult);

	local factionsNode = DB.createChild(jobnode, "factions");
	for _, tFaction in ipairs(tJob.tFactions) do
		local node = DB.createChild(factionsNode);
		DB.setValue(node, "shortcut", "windowreference", "faction", DB.getPath(tFaction.nodeFaction));
		DB.setValue(node, "standing", "number", tFaction.nStanding);
	end
end

function deleteJob(jobNode)
	if not Session.IsHost then
		return;
	end

	if not jobNode then
		return;
	end

	DB.deleteNode(jobNode);
end
