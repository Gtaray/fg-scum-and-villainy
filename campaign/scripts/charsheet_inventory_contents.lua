function onInit()
	local node = getDatabaseNode();
	DB.addHandler(DB.getPath(node, "inventory.load.light"), "onUpdate", onLightLoadChanged)
	DB.addHandler(DB.getPath(node, "inventory.load.normal"), "onUpdate", onNormalLoadChanged)
	DB.addHandler(DB.getPath(node, "inventory.load.heavy"), "onUpdate", onHeavyLoadChanged)
end

function onClose()
	local node = getDatabaseNode();
	DB.removeHandler(DB.getPath(node, "inventory.load.light"), "onUpdate", onLightLoadChanged)
	DB.removeHandler(DB.getPath(node, "inventory.load.normal"), "onUpdate", onNormalLoadChanged)
	DB.removeHandler(DB.getPath(node, "inventory.load.heavy"), "onUpdate", onHeavyLoadChanged)
end

function onLightLoadChanged()
	local node = getDatabaseNode();
	local bSelected = DB.getValue(node, "inventory.load.light", 0) == 1;
	if not bSelected then
		return;
	end

	DB.setValue(node, "inventory.load.normal", "number", 0);
	DB.setValue(node, "inventory.load.heavy", "number", 0);
end

function onNormalLoadChanged()
	local node = getDatabaseNode();
	local bSelected = DB.getValue(node, "inventory.load.normal", 0) == 1;
	if not bSelected then
		return;
	end

	DB.setValue(node, "inventory.load.light", "number", 0);
	DB.setValue(node, "inventory.load.heavy", "number", 0);
end

function onHeavyLoadChanged()
	local node = getDatabaseNode();
	local bSelected = DB.getValue(node, "inventory.load.heavy", 0) == 1;
	if not bSelected then
		return;
	end

	DB.setValue(node, "inventory.load.light", "number", 0);
	DB.setValue(node, "inventory.load.normal", "number", 0);
end

function onEditModeChanged()
	WindowManager.onEditModeChanged(genericitems);
	WindowManager.onEditModeChanged(playbookitems);
end