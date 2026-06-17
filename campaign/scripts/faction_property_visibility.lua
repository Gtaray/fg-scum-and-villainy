function onInit()
	if Session.IsHost then
		return;
	end

	local node = getDatabaseNode();
	local visNode = DB.getPath(DB.getParent(node), "visible");
	DB.addHandler(visNode, "onUpdate", updateVisibility);

	-- Only hide these properties on the client
	updateVisibility();
end

function onClose()
	if Session.IsHost then
		return;
	end

	local node = getDatabaseNode();
	DB.removeHandler(DB.getPath(DB.getParent(node), "visible"), "onUpdate", updateVisibility);
end

function updateVisibility()
	if Session.IsHost then
		return;
	end

	local bVis = DB.getValue(getDatabaseNode(), "..visible", 0) == 1;
	self.update(true, not bVis);
end