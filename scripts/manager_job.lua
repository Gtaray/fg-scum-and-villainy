OOB_MSGTYPE_JOBSHEET_DROP = "jobsheetdrop"
OOB_MSGTYPE_JOBSHEET_UPDATE = "jobsheetupdate"
OOB_MSGTYPE_JOBSHEET_ENGAGEMENTRESULT = "jobsheetengagementresult"

function onInit()
	OOBManager.registerOOBMsgHandler(JobManager.OOB_MSGTYPE_JOBSHEET_DROP, JobManager.handlePlayerDroppedOobMsg);
	OOBManager.registerOOBMsgHandler(JobManager.OOB_MSGTYPE_JOBSHEET_UPDATE, JobManager.handlePlayerUpdateOobMsg);
	OOBManager.registerOOBMsgHandler(JobManager.OOB_MSGTYPE_JOBSHEET_ENGAGEMENTRESULT, JobManager.handleEngagementResultOobMsg);

	WindowTabManager.registerTab("combattracker_host", { sName = "main", sTabRes = "js_tab_main", sClass = "js_main" });
	WindowTabManager.registerTab("combattracker_host", { sName = "notes", sTabRes = "js_tab_notes", sClass = "js_notes" });
	WindowTabManager.registerTab("combattracker_host", { sName = "gmnotes", sTabRes = "js_tab_gmnotes", sClass = "js_gmnotes" });
	WindowTabManager.registerTab("combattracker_host", { sName = "clocks", sTabRes = "js_tab_clocks", sClass = "js_clocks" });

	WindowTabManager.registerTab("combattracker_client", { sName = "main", sTabRes = "js_tab_main", sClass = "js_main" });
	WindowTabManager.registerTab("combattracker_client", { sName = "notes", sTabRes = "js_tab_notes", sClass = "js_notes" });
	WindowTabManager.registerTab("combattracker_client", { sName = "clocks", sTabRes = "js_tab_clocks", sClass = "js_clocks" });

	ToolbarManager.registerButton("export_job", 
		{
			sType = "action",
			sIcon = "button_toolbar_export",
			sTooltipRes = "button_toolbar_export_job",
			fnActivate = JobManager.promptToExport,
			bHostOnly = true,
		});
end

function onTabletopInit()
	if Session.IsHost then
		for _,v in ipairs(JobManager.getCrewMembers()) do
			JobManager.linkPCFields(v);
		end

		DB.addHandler("charsheet.*", "onDelete", JobManager.onCharDelete);
	end
end

function getDatabaseNode()
	if Session.IsHost then
		return DB.createNode(CombatManager.CT_MAIN_PATH);
	else
		return DB.findNode(CombatManager.CT_MAIN_PATH);
	end
end

-------------------------------------------------------------------------------
-- DB CALLBACK REGISTRATIONS
-------------------------------------------------------------------------------
function registerCallback(sPath, sTrigger, fCallback)
	DB.addHandler(DB.getPath(JobManager.getDatabaseNode(), sPath), sTrigger, fCallback)
end

function unregisterCallback(sPath, sTrigger, fCallback)
	DB.removeHandler(DB.getPath(JobManager.getDatabaseNode(), sPath), sTrigger, fCallback)
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

function sendEngagementResultOobMsg(nResult)
	if not nResult then
		return;
	end

	local msg = {
		type = JobManager.OOB_MSGTYPE_JOBSHEET_ENGAGEMENTRESULT,
		nResult = nResult
	};

	Comm.deliverOOBMessage(msg);
end

function handleEngagementResultOobMsg(msg)
	if not Session.IsHost then
		return;
	end

	JobManager.setEngagementRollResult(tonumber(msg.nTotal));
end

----------------------------------------------------------------------------------
-- ON DROP
----------------------------------------------------------------------------------
function handleDrop(draginfo)
	if draginfo.isType("shortcut") or draginfo.isType("token") then
		local sClass, sRecord = draginfo.getShortcutData();
		local node = DB.findNode(sRecord)

		-- Only GM should be able to drop items? Maybe trigger an OOB
		if not Session.IsHost then
			JobManager.sendPlayerDroppedOobMsg(sClass, node);
		else
			JobManager.handleDropNode(sClass, node);
		end
	elseif draginfo.isType("token") then

	end
end

function handleDropNode(sClass, node)
	if RecordDataManager.isRecordTypeDisplayClass("quest", sClass) then
		return JobManager.setJob(node);
	elseif RecordDataManager.isRecordTypeDisplayClass("system", sClass) then
		JobManager.setSystemNode(node);
	elseif RecordDataManager.isRecordTypeDisplayClass("faction", sClass) then
		JobManager.addFaction(node);
	elseif RecordDataManager.isRecordTypeDisplayClass("clock", sClass) then
		ClockManager.handleClockDroppedOnRecord(JobManager.getDatabaseNode(), node);
	elseif RecordDataManager.isRecordTypeDisplayClass("charsheet", sClass) then
		JobManager.addCrewMember(node)
	end
end

----------------------------------------------------------------------------------
-- BASIC INFO
----------------------------------------------------------------------------------
function setJob(nodeJob)
	if not nodeJob then
		return;
	end

	local jsNode = JobManager.getDatabaseNode();
	DB.setValue(jsNode, "job.name", "string", DB.getValue(nodeJob, "name", ""));
	DB.setValue(jsNode, "job.payout", "number", DB.getValue(nodeJob, "payout", 0));

	local _, sSystemNode = DB.getValue(nodeJob, "systemlink", "", "");
	JobManager.setSystemNode(sSystemNode);

	JobManager.clearFactions();

	for _, factionNode in ipairs(DB.getChildList(nodeJob, "factions")) do
		local nStanding = DB.getValue(factionNode, "standing", 0);
		local _, sFactionRecord = DB.getValue(factionNode, "shortcut", "", "");
		JobManager.addFaction(DB.findNode(sFactionRecord), nStanding);
	end

	DB.setValue(jsNode, "job.description", "formattedtext", DB.getValue(nodeJob, "notes", ""));
	DB.setValue(jsNode, "job.notes", "formattedtext", ""); -- This doesn't exist on the quest record
	DB.setValue(jsNode, "job.gmnotes", "formattedtext", DB.getValue(nodeJob, "gmnotes", ""));
end

function clearJob()
	if not Session.IsHost then
		return;
	end

	local jsNode = JobManager.getDatabaseNode();
	DB.setValue(jsNode, "job.name", "string", "");
	DB.setValue(jsNode, "job.payout", "number", 0);
	DB.setValue(jsNode, "job.systemlink", "windowreference", "", "");
	DB.setValue(jsNode, "job.description", "formattedtext", "");
	DB.setValue(jsNode, "job.notes", "formattedtext", "");
	DB.setValue(jsNode, "job.gmnotes", "formattedtext", "");
	DB.deleteChildren(jsNode, "clocks");
	JobManager.clearFactions();
	JobManager.clearEngagement();

end

function getName()
	return DB.getValue(JobManager.getDatabaseNode(), "job.name", "");
end

function getDescription()
	return DB.getValue(JobManager.getDatabaseNode(), "job.description", "");
end

function getNotes()
	return DB.getValue(JobManager.getDatabaseNode(), "job.notes", "");
end

function getGmNotes()
	return DB.getValue(JobManager.getDatabaseNode(), "job.gmnotes", "");
end

function setSystemNode(vSystem)
	if not vSystem then
		return
	end

	if type(vSystem) == "databasenode" then
		vSystem = DB.getPath(vSystem)
	end

	-- Have to set the system as a public node so the players can see it.
	DB.setPublic(vSystem, true);
	DB.setValue(JobManager.getDatabaseNode(), "job.systemlink", "windowreference", "system", vSystem);
end

function getSystemNode()
	local _, sPath = DB.getValue(JobManager.getDatabaseNode(), "job.systemlink", "", "")
	return DB.findNode(sPath);
end

function getPayout()
	return DB.getValue(JobManager.getDatabaseNode(), "job.payout", 0);
end

function clearFactions()
	local nodeFactions = DB.createChild(JobManager.getDatabaseNode(), "job.factions");
	DB.deleteChildren(nodeFactions);
end

function addFaction(factionNode, nStanding)
	if not factionNode then
		return;
	end

	if not nStanding then
		nStanding = 0;
	end

	local nodeFactions = DB.createChild(JobManager.getDatabaseNode(), "job.factions");
	local newFactionNode = DB.createChild(nodeFactions);

	DB.setValue(newFactionNode, "standing", "number", nStanding);
	DB.setValue(newFactionNode, "shortcut", "windowreference", "faction", DB.getPath(factionNode));

	return newFactionNode;
end

function getFactions()
	local tFactions = {}

	for _, node in ipairs(DB.getChildList(JobManager.getDatabaseNode(), "job.factions")) do
		local _, sPath = DB.getValue(node, "shortcut", "", "");
		local tFaction = {
			nStanding = DB.getValue(node, "standing", 0),
			nodeFaction = DB.findNode(sPath)
		}
		table.insert(tFactions, tFaction);
	end

	return tFactions;
end

----------------------------------------------------------------------------------
-- CHARACTERS AND CREW
----------------------------------------------------------------------------------
local aEntryMap = {};
local aFieldMap = {};

function getCrewMembers()
	return DB.getChildList(JobManager.getDatabaseNode(), "crew");
end

function mapCharToJS(nodeChar)
	if not nodeChar then return nil; end
	
	local sChar = DB.getPath(nodeChar);
	for _,v in ipairs(JobManager.getCrewMembers()) do
		local sClass, sRecord = DB.getValue(v, "link", "", "");
		if sRecord == sChar then
			return v;
		end
	end
	return nil;
end

function mapJStoChar(nodeJS)
	if not nodeJS then return nil; end
	
	local sClass, sRecord = DB.getValue(nodeJS, "link", "", "");
	if sRecord == "" then return nil; end
	return DB.findNode(sRecord);
end

function addCrewMember(nodeChar)
	local nodeJS = JobManager.mapCharToJS(nodeChar)
	if nodeJS then
		return;
	end
	
	nodeJS = DB.createChild(DB.getPath(JobManager.getDatabaseNode(), "crew"));
	DB.setValue(nodeJS, "link", "windowreference", "charsheet", DB.getPath(nodeChar));
	JobManager.linkPCFields(nodeJS);
end

function linkPCFields(nodeJS)
	local nodeChar = JobManager.mapJStoChar(nodeJS);
	JobManager.linkRecordField(nodeChar, nodeJS, "name", "string");
	JobManager.linkRecordField(nodeChar, nodeJS, "health.stress.current", "number");
	JobManager.linkRecordField(nodeChar, nodeJS, "health.stress.max", "number");
end

function linkRecordField(nodeRecord, nodePS, sField, sType, sJSField)
	if not nodeRecord then return; end
	
	if not sJSField then
		sJSField = sField;
	end

	local sPath = DB.getPath(nodePS);
	if not aEntryMap[sPath] then
		DB.addHandler(sPath, "onDelete", JobManager.onEntryDeleted);
		aEntryMap[sPath] = true;
	end
	
	local nodeField = DB.createChild(nodeRecord, sField, sType);
	DB.addHandler(nodeField, "onUpdate", JobManager.onLinkUpdated);
	DB.addHandler(nodeField, "onDelete", JobManager.onLinkDeleted);
	
	aFieldMap[DB.getPath(nodeField)] = DB.getPath(nodePS, sJSField);
	JobManager.onLinkUpdated(nodeField);
end

function onLinkUpdated(nodeField)
	DB.setValue(aFieldMap[DB.getPath(nodeField)], DB.getType(nodeField), DB.getValue(nodeField));
end

function onLinkDeleted(nodeField)
	local sFieldName = DB.getPath(nodeField);
	aFieldMap[sFieldName] = nil;
	DB.removeHandler(sFieldName, 'onUpdate', JobManager.onLinkUpdated);
	DB.removeHandler(sFieldName, 'onDelete', JobManager.onLinkDeleted);
end

function onEntryDeleted(nodePS)
	local sPath = DB.getPath(nodePS);
	if aEntryMap[sPath] then
		DB.removeHandler(sPath, "onDelete", JobManager.onEntryDeleted);
		aEntryMap[sPath] = nil;
		
		for k,v in pairs(aFieldMap) do
			if string.sub(v, 1, sPath:len()) == sPath then
				aFieldMap[k] = nil;
				DB.removeHandler(k, "onUpdate", JobManager.onLinkUpdated);
				DB.removeHandler(k, "onDelete", JobManager.onLinkDeleted);
			end
		end
	end
end

function onCharDelete(nodeChar)
	local nodeJS = PartyManager.mapChartoPS(nodeChar);
	if nodeJS then
		DB.deleteNode(nodeJS);
	end
end

----------------------------------------------------------------------------------
-- ENGAGEMENT
----------------------------------------------------------------------------------
function getEngagementPlan()
	return DB.getValue(JobManager.getDatabaseNode(), "engagement.plan", "");
end

function getEngagementDice()
	return DB.getValue(JobManager.getDatabaseNode(), "engagement.dice", 1);
end

function getEngagementResult()
	return DB.getValue(JobManager.getDatabaseNode(), "engagement.startingposition", "");
end

function setEngagementRollResult(nResult)
	if not nResult then
		return;
	end

	local sStartingPosition = Interface.getString("position_controlled")
	if nResult <= 3 then
		sStartingPosition = Interface.getString("position_desperate");
	elseif nResult <= 5 then
		sStartingPosition = Interface.getString("position_risky");
	end

	DB.setValue(JobManager.getDatabaseNode(), "engagement.startingposition", "string", sStartingPosition);
end

function clearEngagement()
	local jsNode = JobManager.getDatabaseNode();
	DB.setValue(jsNode, "engagement.plan", "string", "");
	DB.setValue(jsNode, "engagement.notes", "formattedtext", "");
	DB.setValue(jsNode, "engagement.dice", "number", 0);
	DB.setValue(jsNode, "engagement.startingposition", "string", "");
end

function performEngagementRoll(draginfo)
	local rAction = {
		sLabel = JobManager.getEngagementPlan(),
		nDice = JobManager.getEngagementDice()
	};

	ActionEngagement.performRoll(draginfo, rAction);
end

----------------------------------------------------------------------------------
-- TO CREW SHEET
----------------------------------------------------------------------------------
function promptToExport()
	local tData = {
		sTitleRes = "js_title_export_prompt",
		sTextRes = "js_text_export_prompt",
		fnCallback = JobManager.exportJob
	};

	DialogManager.openDialog("dialog_okcancel", tData);
end

function exportJob(sResult, tData)
	if sResult == "ok" then
		local tJob = JobManager.buildJobTable();
		CrewManager.addJobFromJobSheet(tJob);
		JobManager.clearJob();
	end
end

function buildJobTable()
	return {
		sName = JobManager.getName(),
		nodeSystem = JobManager.getSystemNode(),
		sDescription = JobManager.getDescription(),
		nPayout = JobManager.getPayout(),
		tFactions = JobManager.getFactions(),
		sEngagementPlan = JobManager.getEngagementPlan(),
		sEngagementResult = JobManager.getEngagementResult(),
		sNotes = JobManager.getNotes(),
		sGmNotes = JobManager.getGmNotes()
	};
end