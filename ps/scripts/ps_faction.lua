local _sFactionNodeName = "";

function onInit()
	local node = getDatabaseNode();
	DB.addHandler(DB.getPath(node, "link"), "onUpdate", onLinkChanged);
	DB.addHandler(DB.getPath(node, "status"), "onUpdate", onStatusChanged);

	self.onLinkChanged();
end

function onClose()
	local node = getDatabaseNode();
	DB.removeHandler(DB.getPath(node, "link"), "onUpdate", onLinkChanged);
	DB.removeHandler(DB.getPath(node, "status"), "onUpdate", onStatusChanged);
	
	self.setLinkNode("");
end

-------------------------------------------------------------------------------
--- LINK SETTING
-------------------------------------------------------------------------------
function onLinkChanged()
	local node = self.getFactionNode()
	local sRecord = "";
	if node then
		sRecord = DB.getPath(node);
	end
	
	self.setLinkNode(sRecord);
end

function setLinkNode(sNewLinkNodeName)
	sNewLinkNodeName = sNewLinkNodeName or "";

	if _sFactionNodeName ~= "" then
		DB.removeHandler(_sFactionNodeName, "onChildUpdate", self.update);
	end
	_sFactionNodeName = sNewLinkNodeName;
	if _sFactionNodeName ~= "" then
		DB.addHandler(_sFactionNodeName, "onChildUpdate", self.update);
	end

	self.update();
end

-------------------------------------------------------------------------------
--- UPDATING DISPLAY
-------------------------------------------------------------------------------
function onStatusChanged()
	self.update();
end

function update()
	local node = self.getFactionNode();
	header.setValue(DB.getValue(node, "name", ""));
	self.setStatusTooltip();

	content.subwindow.update();
end

function setStatusTooltip()
	local nValue = DB.getValue(getDatabaseNode(), "status", 0);
	local sRes = string.format("ps_tooltip_factionstatus_%s", nValue);
	status.setTooltipText(Interface.getString(sRes));
end

-------------------------------------------------------------------------------
--- HELPERS
-------------------------------------------------------------------------------
function getFactionNode()
	local _, sRecord = DB.getValue(getDatabaseNode(), "link", "", "")
	return DB.findNode(sRecord);
end