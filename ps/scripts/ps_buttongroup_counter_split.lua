-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local _bInit = false;

local _tSlots = {};
local _nMaxSlotsPerRow = 10;
local _nDefaultSpacing = 10;
local _nSpacing = _nDefaultSpacing;

local _sMaxNodeName = "";
local _sTopNodeName = "";
local _sBottomNodeName = "";

local _nLocalMax = 0;
local _nLocalTop = 0;
local _nLocalBottom = 0;

function onInit()
	-- Get any custom fields
	if values then
		if values[1].maximum then
			_nLocalMax = tonumber(values[1].maximum[1]) or 0;
		end
		if values[1].top then
			_nLocalTop = tonumber(values[1].top[1]) or 0;
		end
		if values[1].bottom then
			_nLocalBottom = tonumber(values[1].bottom[1]) or 0;
		end
	end
	if maxslotperrow then
		_nMaxSlotsPerRow = tonumber(maxslotperrow[1]) or 10;
	end

	-- Synch to the data nodes
	local nodeWin = window.getDatabaseNode();
	if nodeWin then
		local sLoadMaxNodeName = "";
		local sLoadTopNodeName = "";
		local sLoadBottomNodeName = "";
		
		if sourcefields then
			if sourcefields[1].maximum then
				sLoadMaxNodeName = sourcefields[1].maximum[1];
			end
			if sourcefields[1].top then
				sLoadTopNodeName = sourcefields[1].top[1];
			end
			if sourcefields[1].bottom then
				sLoadBottomNodeName = sourcefields[1].bottom[1];
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
		if sLoadTopNodeName ~= "" then
			self.setTopNode(DB.getPath(nodeWin, sLoadTopNodeName));
		end
		if sLoadBottomNodeName ~= "" then
			self.setBottomNode(DB.getPath(nodeWin, sLoadBottomNodeName));
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
	self.setTopNode("");
	self.setBottomNode("");
end

function onMenuSelection(selection)
	if selection == 4 then
		self.setBottomValue(0);
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
	
	local m = self.getMaxValue();
	local c = self.getBottomValue();

	local nClickH = math.floor(x / _nSpacing) + 1;
	local nClickV;
	if m > _nMaxSlotsPerRow then
		nClickV	= math.floor(y / _nSpacing);
	else
		nClickV = 0;
	end
	local nClick = (nClickV * _nMaxSlotsPerRow) + nClickH;

	if nClick > c then
		self.adjustCounter(1);
	else
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

	local m = self.getMaxValue();
	local t = self.getTopValue();
	local b = self.getBottomValue();
	
	if #_tSlots ~= m then
		-- Clear
		for _,v in ipairs(_tSlots) do
			v.destroy();
		end
		_tSlots = {};

		-- Build slots
		for i = 1, m do
			local sIcon = self.calculateIcon(i, t, b);
			local nW = (i - 1) % _nMaxSlotsPerRow;
			local nH = math.floor((i - 1) / _nMaxSlotsPerRow);
			local nX = (_nSpacing * nW) + math.floor(_nSpacing / 2);
			local nY;
			if m > _nMaxSlotsPerRow or allowsinglespacing then
				nY = (_nSpacing * nH) + math.floor(_nSpacing / 2);
			else
				nY = (_nSpacing * nH) + _nSpacing;
			end

			_tSlots[i] = addBitmapWidget({ icon = sIcon, position = "topleft", x = nX, y = nY });
		end
		
		if m > _nMaxSlotsPerRow then
			setAnchoredWidth(_nMaxSlotsPerRow * _nSpacing);
			setAnchoredHeight((math.floor((m - 1) / _nMaxSlotsPerRow) + 1) * _nSpacing);
		else
			setAnchoredWidth(m * _nSpacing);
			if allowsinglespacing then
				setAnchoredHeight(_nSpacing);
			else
				setAnchoredHeight(_nSpacing * 2);
			end
		end
	else
		for i = 1, m do
			_tSlots[i].setBitmap(self.calculateIcon(i, t, b));
		end
	end
end

function calculateIcon(i, t, b)
	local bTop = i <= t;
	local bBottom = i <= b;
	local sIcon;

	if bTop and bBottom then
		sIcon = stateicons[1].both[1];
	elseif bTop then
		sIcon = stateicons[1].top[1];
	elseif bBottom then
		sIcon = stateicons[1].bottom[1];
	else
		sIcon = stateicons[1].off[1];
	end
	return sIcon;
end

-- TODO: Make it configurable whether this edits the top or bottom row
function adjustCounter(nAdj)
	local m = self.getMaxValue();
	local c = self.getBottomValue() + nAdj;
	
	c = math.min(math.max(c, 0), m);
	self.setBottomValue(c);
end
function checkBounds()
	local m = self.getMaxValue();
	local c = self.getBottomValue();
	
	if c > m then
		self.setBottomValue(m);
	elseif c < 0 then
		self.setBottomValue(0);
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

function getTopValue()
	if _sTopNodeName ~= "" then
		return DB.getValue(_sTopNodeName, 0);
	end
	return _nLocalTop;
end
function setTopValue(n)
	if not Session.IsHost then
		CrewManager.sendPlayerUpdateOobMsg(_sTopNodeName, "number", n);
		return;
	end

	if _sTopNodeName ~= "" then
		DB.setValue(_sTopNodeName, "number", n);
	else
		_nLocalTop = n;
	end
end
function setTopNode(sNewTopNodeName)
	if _sTopNodeName ~= "" then
		DB.removeHandler(_sTopNodeName, "onUpdate", self.update);
	end
	_sTopNodeName = sNewTopNodeName;
	if _sTopNodeName ~= "" then
		DB.addHandler(_sTopNodeName, "onUpdate", self.update);
	end
	self.updateSlots();
end

function getBottomValue()
	if _sBottomNodeName ~= "" then
		return DB.getValue(_sBottomNodeName, 0);
	end
	return _nLocalBottom;
end
function setBottomValue(n)
	if not Session.IsHost then
		CrewManager.sendPlayerUpdateOobMsg(_sBottomNodeName, "number", n);
		return;
	end

	if _sBottomNodeName ~= "" then
		DB.setValue(_sBottomNodeName, "number", n);
	else
		_nLocalBottom = n;
	end
end
function setBottomNode(sNewBottomNodeName)
	if _sBottomNodeName ~= "" then
		DB.removeHandler(_sBottomNodeName, "onUpdate", self.update);
	end
	_sBottomNodeName = sNewBottomNodeName;
	if _sBottomNodeName ~= "" then
		DB.addHandler(_sBottomNodeName, "onUpdate", self.update);
	end
	self.updateSlots();
end