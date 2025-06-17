-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local _bInit = false;

local _tSlots = {};
local _nDefaultSpacing = 10;
local _nSpacing = _nDefaultSpacing;

local _sMaxNodeName = "";
local _sMinNodeName = "";
local _sCurNodeName = "";

local _nLocalMax = 0;
local _nLocalMin = 0;
local _nLocalCur = 0;

function onInit()
	-- Get any custom fields
	if values then
		if values[1].maximum then
			_nLocalMax = tonumber(values[1].maximum[1]) or 0;
		end
		if values[1].minimum then
			_nLocalMin = tonumber(values[1].minimum[1]) or 0;
		end
		if values[1].current then
			_nLocalCur = tonumber(values[1].current[1]) or 0;
		end
	end

	-- Synch to the data nodes
	local nodeWin = window.getDatabaseNode();
	if nodeWin then
		local sLoadMaxNodeName = "";
		local sLoadMinNodeName = "";
		local sLoadCurNodeName = "";
		
		if sourcefields then
			if sourcefields[1].maximum then
				sLoadMaxNodeName = sourcefields[1].maximum[1];
			end
			if sourcefields[1].minimum then
				sLoadMinNodeName = sourcefields[1].minimum[1];
			end
			if sourcefields[1].current then
				sLoadCurNodeName = sourcefields[1].current[1];
			end
		end
		
		if sLoadMaxNodeName ~= "" then
			if not DB.getValue(nodeWin, sLoadMaxNodeName) then
				if not Session.IsHost then
					CrewManager.sendPlayerUpdateOobMsg(DB.getPath(nodeWin, sLoadMaxNodeName), "number", 1)
				else
					DB.setValue(nodeWin, sLoadMaxNodeName, "number", 1);
				end
			end
			self.setMaxNode(DB.getPath(nodeWin, sLoadMaxNodeName));
		end
		if sLoadMinNodeName ~= "" then
			if not DB.getValue(nodeWin, sLoadMinNodeName) then
				if not Session.IsHost then
					CrewManager.sendPlayerUpdateOobMsg(DB.getPath(nodeWin, sLoadMinNodeName), "number", 1)
				else
					DB.setValue(nodeWin, sLoadMinNodeName, "number", 1);
				end
			end
			self.setMinNode(DB.getPath(nodeWin, sLoadMinNodeName));
		end
		if sLoadCurNodeName ~= "" then
			self.setCurrentNode(DB.getPath(nodeWin, sLoadCurNodeName));
		end
	end
	
	if spacing then
		_nSpacing = tonumber(spacing[1]) or _nDefaultSpacing;
	end
	if allowsinglespacing then
		setAnchoredHeight(_nSpacing);
	else
		setAnchoredHeight(_nSpacing * 2);
	end
	setAnchoredWidth(_nSpacing);

	_bInit = true;
	
	self.updateSlots();

	registerMenuItem(Interface.getString("counter_menu_clear"), "erase", 4);
end
function onClose()
	_bInit = false;
	
	self.setMaxNode("");
	self.setCurrentNode("");
end

function onMenuSelection(selection)
	if selection == 4 then
		self.setCurrentValue(0);
	end
end
function onWheel(notches)
	if isReadOnly() then
		return;
	end
	if not Input.isControlPressed() then
		return false;
	end

	self.adjustCounter(notches);
	return true;
end
function onClickDown(button, x, y)
	if isReadOnly() then
		return;
	end
	return true;
end
function onClickRelease(button, x, y)
	if isReadOnly() then
		return;
	end
	
	local m = self.getMinValue();
	local c = self.getCurrentValue();

	local nClickH = math.floor(x / _nSpacing) + 1;
	local nClick = nClickH - (1 + math.abs(m));

	if nClick > c or (nClick == c and c < 0) then
		self.adjustCounter(1);
	elseif nClick < c or (nClick == c and c > 0) then
		self.adjustCounter(-1);
	end

	return true;
end

function update()
	self.updateSlots();
	
	if self.onValueChanged then
		self.onValueChanged();
	end
end
function updateSlots()
	if not _bInit then
		return;
	end
	
	self.checkBounds();

	local max = self.getMaxValue();
	local min = self.getMinValue();
	local cur = self.getCurrentValue();

	-- the offset to zero maps the icon that represents 0 to its index in _tSlots
	-- _tSlots starts at 1, but our values range from min to max
	-- So we need to offset i to get the icon for the correct slot in the slider
	-- Also this only works if min and max are symmetrical.
	-- It'll break if they're not equidistant from 0
	local nOffsetToZero = 1 + math.abs(min);
	local range = max - min + 1;
	
	if #_tSlots ~= range then
		-- Clear
		for _,v in ipairs(_tSlots) do
			v.destroy();
		end
		_tSlots = {};

		-- Build slots
		for i = 1, range do
			local nModIndex = i - nOffsetToZero;
			local sIcon = self.calculateIcon(nModIndex, cur, min, max);
			local nW = i - 1;
			local nH = 0;
			local nX = (_nSpacing * nW) + math.floor(_nSpacing / 2);
			local nY;
			if allowsinglespacing then
				nY = (_nSpacing * nH) + math.floor(_nSpacing / 2);
			else
				nY = (_nSpacing * nH) + _nSpacing;
			end

			_tSlots[i] = addBitmapWidget({ icon = sIcon, position = "topleft", x = nX, y = nY });
		end

		setAnchoredWidth(range * _nSpacing);
		if allowsinglespacing then
			setAnchoredHeight(_nSpacing);
		else
			setAnchoredHeight(_nSpacing * 2);
		end
	else
		for i = 1, range do
			local nModIndex = i - nOffsetToZero;
			_tSlots[i].setBitmap(self.calculateIcon(nModIndex, cur, min, max));
		end
	end
end

function calculateIcon(i, c, min, max)
	if (c < 0 and i <= 0 and i >= c) then
		return stateicons[1].negative[1]
	end

	if (c >= 0 and i >= 0 and i <= c) then
		return stateicons[1].positive[1];
	end

	return stateicons[1].base[1];
end

function adjustCounter(nAdj)
	local max = self.getMaxValue();
	local min = self.getMinValue();
	local cur = self.getCurrentValue() + nAdj;
	
	cur = math.min(math.max(cur, min), max);
	self.setCurrentValue(cur);
end
function checkBounds()
	local max = self.getMaxValue();
	local min = self.getMinValue();
	local cur = self.getCurrentValue();
	
	if cur > max then
		self.setCurrentValue(max);
	elseif cur < min then
		self.setCurrentValue(min);
	end
end

function getMaxValue()
	if _sMaxNodeName ~= "" then
		return DB.getValue(_sMaxNodeName, 0);
	end
	return _nLocalMax;
end
function setMaxValue(n)
	if not Session.IsHost then
		CrewManager.sendPlayerUpdateOobMsg(_sMaxNodeName, "number", n);
		return;
	end

	if _sMaxNodeName ~= "" then
		DB.setValue(_sMaxNodeName, "number", n);
	else
		_nLocalMax = n;
	end
end
function setMaxNode(sNewMaxNodeName)
	if _sMaxNodeName ~= "" then
		DB.removeHandler(_sMaxNodeName, "onUpdate", self.update);
	end
	_sMaxNodeName = sNewMaxNodeName;
	if _sMaxNodeName ~= "" then
		DB.addHandler(_sMaxNodeName, "onUpdate", self.update);
	end
	self.updateSlots();
end

function getMinValue()
	if _sMinNodeName ~= "" then
		return DB.getValue(_sMinNodeName, 0);
	end
	return _nLocalMin;
end
function setMinValue(n)
	if not Session.IsHost then
		CrewManager.sendPlayerUpdateOobMsg(_sMinNodeName, "number", n);
		return;
	end

	if _sMinNodeName ~= "" then
		DB.setValue(_sMinNodeName, "number", n);
	else
		_nLocalMin = n;
	end
end
function setMinNode(sNewMinNodeName)
	if _sMinNodeName ~= "" then
		DB.removeHandler(_sMinNodeName, "onUpdate", self.update);
	end
	_sMinNodeName = sNewMinNodeName;
	if _sMinNodeName ~= "" then
		DB.addHandler(_sMinNodeName, "onUpdate", self.update);
	end
	self.updateSlots();
end

function getCurrentValue()
	if _sCurNodeName ~= "" then
		return DB.getValue(_sCurNodeName, 0);
	end
	return _nLocalCur;
end
function setCurrentValue(n)
	if not Session.IsHost then
		CrewManager.sendPlayerUpdateOobMsg(_sCurNodeName, "number", n);
		return;
	end

	if _sCurNodeName ~= "" then
		DB.setValue(_sCurNodeName, "number", n);
	else
		_nLocalCur = n;
	end
end
function setCurrentNode(sNewCurNodeName)
	if _sCurNodeName ~= "" then
		DB.removeHandler(_sCurNodeName, "onUpdate", self.update);
	end
	_sCurNodeName = sNewCurNodeName;
	if _sCurNodeName ~= "" then
		DB.addHandler(_sCurNodeName, "onUpdate", self.update);
	end
	self.updateSlots();
end