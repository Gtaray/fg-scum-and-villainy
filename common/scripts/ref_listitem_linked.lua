local _sNameNode = "";

function onInit()
	DB.addHandler(DB.getPath(getDatabaseNode(), "shortcut"), "onUpdate", onLinkChanged)

	self.onLinkChanged();
end

function onClose()
	DB.removeHandler(DB.getPath(getDatabaseNode(), "shortcut"), "onUpdate", onLinkChanged)
end

function onLinkChanged()
	local _, sRecord = shortcut.getValue();
	local node = DB.findNode(sRecord)
	if not node then
		self.setNameLink("");
	end

	self.setNameLink(DB.getPath(node, "name"));
end

function update()
	local bEmpty = shortcut.isEmpty();
	shortcut.setVisible(not bEmpty);
	name.setValue(self.getNameValue())
end

function setNameLink(sNewNameNode)
	if _sNameNode ~= "" then
		DB.removeHandler(_sNameNode, "onUpdate", self.update);
	end
	_sNameNode = sNewNameNode;
	if _sNameNode ~= "" then
		DB.addHandler(_sNameNode, "onUpdate", self.update);
	end
	self.update();
end

function getNameValue()
	return DB.getValue(_sNameNode, "");
end