-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

-- Ruleset action types
actions = {
	["dice"] = { bUseModStack = "true" },
	["table"] = { },
	["effect"] = { sIcon = "action_effect", sTargeting = "all" },
	
    ["action"] = { sIcon = "action_roll" },
    ["resistance"] = { sIcon = "action_roll" },
    ["stress"] = { sIcon = "action_roll" },
    ["engagement"] = { sIcon = "action_roll" },
    ["fortune"] = { sIcon = "action_roll" }
};

targetactions = { };
currencies = { };
currencyDefault = nil;

-- Has to be defined before the table
function getTypeFilterValues(vNode)
	if not vNode then
		return {};
	end
	return StringManager.split(DB.getValue(vNode, "type", ""), ",", true);
end

aRecordOverrides = {
	["playbook"] = {
		bExport = true,
		aDataMap = { "playbook", "reference.playbook" },
		sRecordDisplayClass = "playbook",
		sSidebarCategory = "create"
	},
	["ability"] = {
		bExport = true,
		aDataMap = { "ability", "reference.ability" },
		sRecordDisplayClass = "ability",
		sSidebarCategory = "create",
		aCustomFilters = {
			["Type"] = { sField = "type", fGetValue = getTypeFilterValues }
		}
	},
	["heritage"] = {
		bExport = true,
		aDataMap = { "heritage", "reference.heritage" },
		sRecordDisplayClass = "heritage",
		sSidebarCategory = "create",
	},
	["background"] = {
		bExport = true,
		aDataMap = { "background", "reference.background" },
		sRecordDisplayClass = "background",
		sSidebarCategory = "create",
	},
	["crew"] = {
		bExport = true,
		aDataMap = { "crew", "reference.crew" },
		sRecordDisplayClass = "crew",
		sSidebarCategory = "crew",
	},
	["crewtype"] = {
		bExport = true,
		aDataMap = { "crewtype", "reference.crewtype" },
		sRecordDisplayClass = "crewtype",
		sSidebarCategory = "crew",
	},
	["shiptype"] = {
		bExport = true,
		aDataMap = { "shiptype", "reference.shiptype" },
		sRecordDisplayClass = "shiptype",
		sSidebarCategory = "crew",
	},
	["upgrade"] = {
		bExport = true,
		aDataMap = { "upgrade", "reference.upgrade" },
		sRecordDisplayClass = "upgrade",
		sSidebarCategory = "crew",
		aCustomFilters = {
			["Type"] = { sField = "type", fGetValue = getTypeFilterValues }
		}
	},
	["clock"] = {
		bExport = true,
		aDataMap = { "clock", "reference.clock" },
		sRecordDisplayClass = "clock",
		sSidebarCategory = "campaign"
	},
	["faction"] = {
		bExport = true,
		aDataMap = { "faction", "reference.faction" },
		sRecordDisplayClass = "faction",
		sSidebarCategory = "world"
	},
	["system"] = {
		bExport = true,
		aDataMap = { "system", "reference.system" },
		sRecordDisplayClass = "system",
		sSidebarCategory = "world"
	}
}

function onInit()
	LibraryData.overrideRecordTypes(aRecordOverrides);
	CombatListManager.registerStandardInitSupport();
end

function getCharSelectDetailHost(nodeChar)
	return "";
end

function requestCharSelectDetailClient()
	return "name";
end

function receiveCharSelectDetailClient(vDetails)
	return vDetails, "";
end

function getDistanceUnitsPerGrid()
	return 1;
end
