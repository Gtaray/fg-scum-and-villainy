local _clockSizes = {}

function onInit()
	ClockManager.addClockSize(4, "clock_label_segments");
	ClockManager.addClockSize(6, "clock_label_segments");
	ClockManager.addClockSize(8, "clock_label_segments");
	ClockManager.addClockSize(10, "clock_label_segments");
	ClockManager.addClockSize(12, "clock_label_segments");
end

-------------------------------------------------------------------------------
--- HANDLE DROPPING CLOCKS ON OTHER RECORDS
-------------------------------------------------------------------------------
function handleClockDrop(draginfo, window)
	local winNode = window.getDatabaseNode();
	local bReadOnly = WindowManager.getReadOnlyState(winNode);
	if bReadOnly then
		return true;
	end

	if draginfo.isType("shortcut") then
		local sClass, sRecord = draginfo.getShortcutData();
		local node = DB.findNode(sRecord)
		if RecordDataManager.isRecordTypeDisplayClass("clock", sClass) then
			return ClockManager.handleClockDroppedOnRecord(winNode, node);
		end
	end
end

function handleClockDroppedOnRecord(nodeRecord, nodeClock)
	if not Session.IsHost then
		return;
	end

	local listNode = DB.createChild(nodeRecord, "clocks");
	local newClockNode = listNode.createChild();
	
	-- This errors out with 'attempt to call local nodeClock (a userdata value)'
	local sName = DB.getValue(nodeClock, "name", "Unnamed Clock");
	local nSize = DB.getValue(nodeClock, "size", 4);
	local nProgress = DB.getValue(nodeClock, "progress", 0);
	local sNotes = DB.getValue(nodeClock, "notes", "")

	DB.setValue(newClockNode, "name", "string", sName);
	DB.setValue(newClockNode, "size", "number", nSize);
	DB.setValue(newClockNode, "progress", "number", nProgress);
	DB.setValue(newClockNode, "notes", "formattedtext", sNotes);
end

-------------------------------------------------------------------------------
--- CLOCK DATA INITIALIZATION
-------------------------------------------------------------------------------
function getClockSizes()
	return _clockSizes;
end

function getClockAtIndex(nIndex)
	return _clockSizes[nIndex];
end

function addClockSize(nSize, sResource)
	if not ClockManager.hasClockSize(nSize) then
		local tData = {
			nSize = nSize,
			sResource = sResource
		};
		table.insert(_clockSizes, tData);
	end
end

function removeClockSize()
	local nIndex = ClockManager.getClockDataIndex(nSize);
	if nIndex ~= nil then
		table.remove(_clockSizes, nIndex);
	end
end

function hasClockSize(nSize)
	return ClockManager.getClockDataIndex(nSize) ~= nil;
end

function getClockData(nSize)
	local nIndex = ClockManager.getClockDataIndex(nSize);
	if nIndex ~= nil then
		return _clockSizes[nIndex];
	end
end

function getClockDataIndex(nSize)
	for nIndex, tData in ipairs(_clockSizes) do
		if tData.nSize == nSize then
			return nIndex;
		end
	end
end

-------------------------------------------------------------------------------
--- CHAT MESSAGING
-------------------------------------------------------------------------------
function sendClockToChat(clockNode)
	if not clockNode then
		return;
	end

	local nSize = DB.getValue(clockNode, "size", 0);
	local nProgress = DB.getValue(clockNode, "progress", 0);

	if nSize == 0 then
		return;
	end

	local sName = DB.getValue(clockNode, "name", "");
	if sName == "" then
		sName = "Unnamed Clock"
	end

	local rMessage = {
		text = string.format("[CLOCK] %s: %s/%s", sName, nProgress, nSize),
		font = "systemfont",
		icon = "action_clock"
	}
	Comm.deliverChatMessage(rMessage);
end