local _sSizeNodeName = "";
local _sCurNodeName = "";

function onInit()
	local nodeWin = window.getDatabaseNode();
	if nodeWin then
		local sSizeNodeName = "";
		local sCurrentNodeName = "";

		if sourcefields then
			if sourcefields[1].size then
				sSizeNodeName = sourcefields[1].size[1];
			end
			if sourcefields[1].progress then
				sCurrentNodeName = sourcefields[1].progress[1];
			end
		end

		if sSizeNodeName ~= "" then
			self.setSizeNode(DB.getPath(nodeWin, sSizeNodeName));
		end
		if sCurrentNodeName ~= "" then
			self.setCurrentNode(DB.getPath(nodeWin, sCurrentNodeName));
		end
	end

	self.updateMax();
end

function onClose()
	self.setSizeNode("");
	self.setCurrentNode("");
end

function onWheel(notches)
	if isReadOnly() then
		return;
	end
	if not Input.isControlPressed() then
		return false;
	end

	self.adjustProgress(notches, true);
	return true;
end

function onButtonPress()
	if isReadOnly() then
		return;
	end

	self.adjustProgress(1);
	return true;
end

function updateMax()
	-- When updating clock size, make sure that progress is clamped to the new
	-- maximum
	local s = self.getSizeValue();
	local p = self.getCurrentValue();

	-- When we close the windows, size is set to 0. We don't want to muck with that
	if s == 0 then
		return;
	end

	if p > s then
		self.setCurrentValue(s);
		return; --setCurrentValue will all update, so we can return early and not trigger it twice
	end

	self.update();
end

function update()
	local s = self.getSizeValue();
	local p = self.getCurrentValue();
	
	local i = self.getStateIndex(s)
	if i then
		setValue(i + p);
	end
end

function adjustProgress(nDelta, bStopAtMax)
	local s = self.getSizeValue();
	local p = self.getCurrentValue() + nDelta;

	-- If the progress goes over the max size, wrap it back to 0
	if not bStopAtMax then
		if p > s then
			p = 0;
		end
	end

	p = math.min(math.max(p, 0), s);

	self.setCurrentValue(p);
end

-------------------------------------------------------------------------------
--- GETTERS / SETTERS
-------------------------------------------------------------------------------
function getSizeValue()
	if _sSizeNodeName ~= "" then
		return DB.getValue(_sSizeNodeName, 0);
	end
	return 0;
end
function setSizeValue(n)
	if not Session.IsHost then
		JobManager.sendPlayerUpdateOobMsg(_sSizeNodeName, "number", n)
		return;
	end
	if _sSizeNodeName ~= "" then
		DB.setValue(_sSizeNodeName, "number", n);
	end
end
function setSizeNode(sNewMaxNodeName)
	if _sSizeNodeName ~= "" then
		DB.removeHandler(_sSizeNodeName, "onUpdate", self.updateMax);
	end
	_sSizeNodeName = sNewMaxNodeName;
	if _sSizeNodeName ~= "" then
		DB.addHandler(_sSizeNodeName, "onUpdate", self.updateMax);
	end
	self.updateMax();
end

function getCurrentValue()
	if _sCurNodeName ~= "" then
		return DB.getValue(_sCurNodeName, 0);
	end
	return 0;
end
function setCurrentValue(n)
	if not Session.IsHost then
		JobManager.sendPlayerUpdateOobMsg(_sCurNodeName, "number", n)
		return;
	end
	if _sCurNodeName ~= "" then
		DB.setValue(_sCurNodeName, "number", n);
	end
end
function setCurrentNode(sNewCurrentNodeName)
	if _sCurNodeName ~= "" then
		DB.removeHandler(_sCurNodeName, "onUpdate", self.update);
	end
	_sCurNodeName = sNewCurrentNodeName;
	if _sCurNodeName ~= "" then
		DB.addHandler(_sCurNodeName, "onUpdate", self.update);
	end
	self.update();
end