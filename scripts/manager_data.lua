-- This script manages the data that drives the chracter and crew sheets
-- Namely the character attributes and actions, and the crew's ship sections

local _attributes = {}
local _actions = {}
local _shipSections = {}
local _shipSizes = {}
local _defaultCrewXpTriggers = {}
local _defaultPlaybookXpTriggers = {}
local _engagementPlans = {}

function onInit()
    addAttribute("insight", "attribute_label_insight");
    addAttribute("prowess", "attribute_label_prowess");
    addAttribute("resolve", "attribute_label_resolve");

    addAction("doctor", "insight", "action_label_doctor");
    addAction("hack", "insight", "action_label_hack");
    addAction("rig", "insight", "action_label_rig");
    addAction("study", "insight", "action_label_study");

    addAction("helm", "prowess", "action_label_helm");
    addAction("scramble", "prowess", "action_label_scramble");
    addAction("scrap", "prowess", "action_label_scrap");
    addAction("skulk", "prowess", "action_label_skulk");

    addAction("attune", "resolve", "action_label_attune");
    addAction("command", "resolve", "action_label_command");
    addAction("consort", "resolve", "action_label_consort");
    addAction("sway", "resolve", "action_label_sway");

    addShipSection("hull", "shipsection_label_hull");
    addShipSection("engines", "shipsection_label_engines");
    addShipSection("weapons", "shipsection_label_weapons");
    addShipSection("comms", "shipsection_label_comms");

	addShipSize("personal", "shipsize_label_personal");
	addShipSize("freighter", "shipsize_label_freighter");
	addShipSize("corvette", "shipsize_label_corvette");
	addShipSize("frigate", "shipsize_label_frigate");
	addShipSize("dreadnaught", "shipsize_label_dreadnaught");

	addDefaultCrewXpTrigger(Interface.getString("crewxptrigger_challenge"));
	addDefaultCrewXpTrigger(Interface.getString("crewxptrigger_reputation"));
	addDefaultCrewXpTrigger(Interface.getString("crewxptrigger_goals"));

	addEngagementPlan("assault");
	addEngagementPlan("deception");
	addEngagementPlan("infiltration");
	addEngagementPlan("mystic");
	addEngagementPlan("social");
	addEngagementPlan("transport");
end

-------------------------------------------------------------------------------
-- ATTRIBUTES
-------------------------------------------------------------------------------
function getAttributes()
    return _attributes;
end

function getAttributeIndex(sAttr)
	sAttr = sAttr:lower();
	for nIndex, attr in ipairs(_attributes) do
		if attr.sAttribute == sAttr then
			return nIndex;
		end
	end
end

function getAttribute(sAttr)
	local nIndex = DataManager.getAttributeIndex(sAttr)
    if not nIndex then
        return;
    end

	return _attributes[nIndex];
end

function addAttribute(sAttribute, sResource)
    if DataManager.hasAttribute(sAttribute) then
        return;
    end
    sAttribute = sAttribute:lower();
    local tData = {
        sAttribute = sAttribute,
        sResource = sResource
    }
	table.insert(_attributes, tData);
end

function removeAttribute(sAttr)
    local nIndex = DataManager.getAttributeIndex(sAttr)
    if not nIndex then
        return;
    end

	table.remove(_attributes, nIndex);
end

function hasAttribute(sAttribute)
    return DataManager.getAttributeIndex(sAttribute) ~= nil;
end

function getAttributeForAction(sAction)
	local action = getAction(sAction);
	if action then
		return DataManager.getAttribute(action.sAttribute)
	end
end

-------------------------------------------------------------------------------
-- ACTIONS
-------------------------------------------------------------------------------
function getActions()
    return _actions;
end

function getActionIndex(sAction)
	sAction = sAction:lower();
	for nIndex, action in ipairs(_actions) do
		if action.sAction == sAction then
			return nIndex;
		end
	end
end

function getAction(sAction)
	local nIndex = DataManager.getActionIndex(sAction)
    if not nIndex then
        return;
    end

	return _actions[nIndex];
end

function addAction(sAction, sAttribute, sResource)
    if DataManager.hasAction(sAction) then
        return;
    end

    local tData = {
        sAction = sAction:lower(),
        sAttribute = sAttribute:lower(),
        sResource = sResource,
    }
	table.insert(_actions, tData);
end

function removeAttribute(sAction)
    local nIndex = DataManager.getActionIndex(sAction)
    if not nIndex then
        return;
    end

	table.remove(_actions, nIndex);
end

function hasAction(sAction)
    return DataManager.getActionIndex(sAction) ~= nil;
end

function getActionsForAttribute(sAttribute)
    local result = {}

    sAttribute = sAttribute:lower();
    for nIndex, tData in pairs(DataManager.getActions()) do
        if tData.sAttribute == sAttribute then
            table.insert(result, tData);
        end
    end

    return result;
end

-------------------------------------------------------------------------------
-- SHIP SECTIONS
-------------------------------------------------------------------------------
function getShipSections()
    return _shipSections;
end

function getShipSectionIndex(sSection)
	sSection = sSection:lower();
	for nIndex, section in ipairs(_shipSections) do
		if section.sSection == sSection then
			return nIndex;
		end
	end
end

function getShipSection(sSection)
	local nIndex = getShipSectionIndex(sSection)
    if not nIndex then
        return;
    end

	return _shipSections[nIndex]
end

function addShipSection(sSection, sResource)
    if DataManager.hasShipSection(sSection) then
        return;
    end
    sSection = sSection:lower();
    local section = {
        sSection = sSection,
        sResource = sResource
    }
	table.insert(_shipSections, section);
end

function removeShipSystem(sSection)
	local nIndex = getShipSectionIndex(sSection)
    if not nIndex then
        return;
    end

	table.remove(_shipSections, nIndex);
end

function hasShipSection(sSection)
	sSection = sSection:lower();
	for _, section in ipairs(_shipSections) do
		if section.sSection == sSection then
			return true;
		end
	end
    return false;
end

-------------------------------------------------------------------------------
-- SHIP SIZES
-------------------------------------------------------------------------------
function getShipSizes()
    return _shipSizes;
end

function getShipSizeIndex(sSize)
	sSize = sSize:lower();
	for nIndex, section in ipairs(_shipSizes) do
		if section.sSize == sSize then
			return nIndex;
		end
	end
end

function addShipSize(sSize, sResource)
    if DataManager.hasShipSize(sSize) then
        return;
    end
	
    sSize = sSize:lower();
    local size = {
        sSize = sSize,
        sResource = sResource
    }
	table.insert(_shipSizes, size);
end

function removeShipSystem(sSize)
    local nIndex = getShipSizeIndex(sSize)
    if not nIndex then
        return;
    end

	table.remove(_shipSizes, nIndex);
end

function hasShipSize(sSize)
    sSize = sSize:lower();
	for _, section in ipairs(_shipSizes) do
		if section.sSize == sSize then
			return true;
		end
	end
    return false;
end

-------------------------------------------------------------------------------
-- CREW XP TRIGGERS
-------------------------------------------------------------------------------
function addDefaultCrewXpTrigger(sTrigger)
	table.insert(_defaultCrewXpTriggers, sTrigger);
end

function getDefaultCrewXpTriggers()
	return _defaultCrewXpTriggers
end

-------------------------------------------------------------------------------
-- PLAYBOOK XP TRIGGERS
-------------------------------------------------------------------------------
function addDefaultPlaybookXpTrigger(sTrigger)
	table.insert(_defaultPlaybookXpTriggers, sTrigger);
end

function getDefaultPlaybookXpTriggers()
	return _defaultPlaybookXpTriggers
end

-------------------------------------------------------------------------------
-- ENGAGEMENT ROLLS
-------------------------------------------------------------------------------
function addEngagementPlan(sEngagementId)
	if DataManager.hasEngagementPlan(sEngagementId) then
        return;
    end

    sEngagementId = sEngagementId:lower();
	
    local engagement = {
		sId = sEngagementId,
        sLabel = Interface.getString(string.format("engagement_%s_label", sEngagementId)),
        sDescription = Interface.getString(string.format("engagement_%s_description", sEngagementId)),
		sDetail = Interface.getString(string.format("engagement_%s_detail", sEngagementId))
    }
	table.insert(_engagementPlans, engagement);
end

function hasEngagementPlan(sEngagementId)
	return DataManager.getEngagementPlan(sEngagementId) ~= nil
end

function getEngagementPlan(sEngagementId)
	sEngagementId = sEngagementId:lower();
	for _, tEngagement in ipairs(_engagementPlans) do
		if tEngagement.sId == sEngagementId then
			return tEngagement;
		end
	end
end

function getEngagementsPlans()
	return _engagementPlans;
end