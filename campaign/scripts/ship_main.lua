function onInit()
	self.update();
end

function update()
	local bReadOnly = WindowManager.getReadOnlyState(getDatabaseNode());
	local tFields = { "size", "class", "look", "sections", "auxiliary", "shipgear" };
	WindowManager.callSafeControlsUpdate(self, tFields, bReadOnly);
end

function onDrop(x, y, draginfo)
	if not draginfo.isType("shortcut") then
		return;
	end

	local sClass, sRecord = draginfo.getShortcutData();
	local node = DB.findNode(sRecord);
	if not node then
		return;
	end

	if RecordDataManager.isRecordTypeDisplayClass("shiptype", sClass) then
		self.applyShipType(node);
		return true;
	elseif RecordDataManager.isRecordTypeDisplayClass("upgrade", sClass) then
		return self.handleUpgradeDrop(node);
	end
end

function applyShipType(nodeShipType)
	local nodeRecord = getDatabaseNode();

	DB.setValue(nodeRecord, "size", "string", DB.getValue(nodeShipType, "size", ""));
	DB.setValue(nodeRecord, "class", "string", DB.getValue(nodeShipType, "name", ""));

	-- Apply section ratings and installed upgrades
	for _, nodeSrcSection in ipairs(DB.getChildList(nodeShipType, "sections")) do
		local sSection = DB.getValue(nodeSrcSection, "name", ""):lower();
		local nodeDestSection = self.getOrCreateSection(sSection);
		if nodeDestSection then
			DB.setValue(nodeDestSection, "rating", "number", DB.getValue(nodeSrcSection, "rating", 0));
			DB.setValue(nodeDestSection, "maxrating", "number", DB.getValue(nodeSrcSection, "maxrating", 4));

			DB.deleteChildren(nodeDestSection, "upgrades");
			for _, nodeUpgrade in ipairs(DB.getChildList(nodeSrcSection, "upgrades")) do
                local bGiven = DB.getValue(nodeUpgrade, "given", 0) == 1;
				local _, sUpgradeRecord = DB.getValue(nodeUpgrade, "shortcut", "", "");
                local nodeUpgradeSource = DB.findNode(sUpgradeRecord);
                if nodeUpgradeSource then
                    self.addUpgradeToList(nodeUpgradeSource, string.format("sections.%s.upgrades", DB.getName(nodeDestSection)), bGiven);
                end
			end
		end
	end

	-- Apply auxiliary and ship gear from the shiptype's "other upgrades" list
	DB.deleteChildren(nodeRecord, "upgrades.auxiliary");
	DB.deleteChildren(nodeRecord, "upgrades.shipgear");
	for _, nodeUpgrade in ipairs(DB.getChildList(nodeShipType, "upgrades")) do
		local bGiven = DB.getValue(nodeUpgrade, "given", 0) == 1;
        local _, sUpgradeRecord = DB.getValue(nodeUpgrade, "shortcut", "", "");
        local nodeUpgradeSource = DB.findNode(sUpgradeRecord);
        if nodeUpgradeSource then
            local sType = DB.getValue(nodeUpgradeSource, "type", ""):lower();
            if sType == "auxiliary" then
                self.addUpgradeToList(nodeUpgradeSource, "upgrades.auxiliary", bGiven);
            elseif sType == "ship gear" then
                self.addUpgradeToList(nodeUpgradeSource, "upgrades.shipgear", bGiven);
            end
        end
	end
end

function getOrCreateSection(sSection)
	local nodeRecord = getDatabaseNode();
	local nodeSections = DB.createChild(nodeRecord, "sections");
	for _, nodeSection in ipairs(DB.getChildList(nodeSections)) do
		if DB.getValue(nodeSection, "name", ""):lower() == sSection then
			return nodeSection;
		end
	end
	return nil;
end

function handleUpgradeDrop(nodeUpgrade)
	local sType = DB.getValue(nodeUpgrade, "type", ""):lower();
	local sListPath;

	if DataManager.hasShipSection(sType) then
		local nodeSections = DB.createChild(getDatabaseNode(), "sections");
		for _, nodeSection in ipairs(DB.getChildList(nodeSections)) do
			if DB.getValue(nodeSection, "name", ""):lower() == sType then
				sListPath = string.format("sections.%s.upgrades", DB.getName(nodeSection));
				break;
			end
		end
	elseif sType == "auxiliary" then
		sListPath = "upgrades.auxiliary";
	elseif sType == "ship gear" then
		sListPath = "upgrades.shipgear";
	end

	if not sListPath then
		return;
	end

	self.addUpgradeToList(nodeUpgrade, sListPath, true);
	return true;
end

function addUpgradeToList(nodeUpgrade, sListPath, bGiven)
	local nodeRecord = getDatabaseNode();
	local nodeList = DB.createChild(nodeRecord, sListPath);
	if not nodeList then
		return;
	end

	local sUpgradeName = DB.getValue(nodeUpgrade, "name", "");
	for _, nodeExisting in ipairs(DB.getChildList(nodeList)) do
		if DB.getValue(nodeExisting, "name", "") == sUpgradeName then
			return;
		end
	end

	local nodeNew = DB.createChild(nodeList);
	DB.copyNode(nodeUpgrade, nodeNew);
	DB.setValue(nodeNew, "used", "number", 0);

	if bGiven then
		local nCost = DB.getValue(nodeNew, "cost", 1);
		DB.setValue(nodeNew, "paid", "number", nCost);
	end
end