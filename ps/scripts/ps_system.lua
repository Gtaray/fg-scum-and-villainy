local _sSystemNodeName = "";

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
	local node = self.getSystemNode()
	local sRecord = "";
	if node then
		sRecord = DB.getPath(node);
	end
	
	self.setLinkNode(sRecord);
end

function setLinkNode(sNewLinkNodeName)
	sNewLinkNodeName = sNewLinkNodeName or "";

	if _sSystemNodeName ~= "" then
		DB.removeHandler(_sSystemNodeName, "onChildUpdate", self.update);
	end
	_sSystemNodeName = sNewLinkNodeName;
	if _sSystemNodeName ~= "" then
		DB.addHandler(_sSystemNodeName, "onChildUpdate", self.update);
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
	local node = self.getSystemNode();
	header.setValue(DB.getValue(node, "name", ""));

	content.subwindow.description.setValue(DB.getValue(node, "description", ""));
end

-------------------------------------------------------------------------------
--- HELPERS
-------------------------------------------------------------------------------
function getSystemNode()
	local _, sRecord = DB.getValue(getDatabaseNode(), "link", "", "")
	return DB.findNode(sRecord);
end