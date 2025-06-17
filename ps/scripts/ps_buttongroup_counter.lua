-- 
-- Please see the license.html file included with this distribution for 
-- attribution and copyright information.
--

local DEFAULT_SPACING = 10;
local DEFAULT_MAX_ROW_SLOTS = 10;

function onInit()
	self.initDisplayData();
	self.initSource();

	self.setInitialized(true);
	self.updateSlots();
end
function onClose()
	self.setInitialized(false);
	
	self.setMaxNode("");
	self.setCurrNode("");
end

--
--	ACCESSORS
--

local _bInit = false;
function isInitialized()
	return _bInit;
end
function setInitialized(bValue)
	_bInit = bValue;
end

local _nLocalMax = 0;
function getLocalMax()
	return _nLocalMax;
end
function setLocalMax(n)
	_nLocalMax = n or 0;
end

local _nLocalCurrent = 0;
function getLocalCurrent()
	return _nLocalCurrent;
end
function setLocalCurrent(n)
	_nLocalCurrent = n or 0;
end

local _nSpacing = DEFAULT_SPACING;
function getSpacing()
	return _nSpacing;
end
function setSpacing(n)
	_nSpacing = n or DEFAULT_SPACING;
end

local _nMaxSlotsPerRow = DEFAULT_MAX_ROW_SLOTS;
function getMaxSlotsPerRow()
	return _nMaxSlotsPerRow;
end
function setMaxSlotsPerRow(n)
	_nMaxSlotsPerRow = n or DEFAULT_MAX_ROW_SLOTS;
end

--
--	DATA SOURCE
--

function initSource()
	-- Synch to the data nodes
	local nodeWin = window.getDatabaseNode();
	if nodeWin then
		local sLoadMaxNodeName = "";
		local sLoadCurrNodeName = "";
		
		if sourcefields then
			if sourcefields[1].maximum then
				sLoadMaxNodeName = sourcefields[1].maximum[1];
			end
			if sourcefields[1].current then
				sLoadCurrNodeName = sourcefields[1].current[1];
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
		if sLoadCurrNodeName ~= "" then
			self.setCurrNode(DB.getPath(nodeWin, sLoadCurrNodeName));
		end
	end
end

--
--	DISPLAY DATA
--

local _tSlots = {};
function getSlotsData()
	return _tSlots;
end
function getSlotData(n)
	return _tSlots[n or 0];
end
function clearSlotsData()
	for _,v in ipairs(_tSlots) do
		v.destroy();
	end
	_tSlots = {};
end
function setSlotData(n, wgt)
	_tSlots[n or 0] = wgt;
end

function initDisplayData()
	-- Get any custom fields
	if values then
		if values[1].maximum then
			self.setLocalMax(tonumber(values[1].maximum[1]));
		end
		if values[1].current then
			self.setLocalCurrent(tonumber(values[1].current[1]));
		end
	end
	if maxslotperrow then
		self.setMaxSlotsPerRow(tonumber(maxslotperrow[1]));
	end

	if spacing then
		self.setSpacing(tonumber(spacing[1]));
	end

	local nSpacing = self.getSpacing();
	if allowsinglespacing then
		setAnchoredHeight(nSpacing);
	else
		setAnchoredHeight(nSpacing * 2);
	end
	setAnchoredWidth(nSpacing);

	registerMenuItem(Interface.getString("counter_menu_clear"), "erase", 4);
end

function update()
	self.updateSlots();
	
	if self.onValueChanged then
		self.onValueChanged();
	end
end
function updateSlots()
	if not self.isInitialized() then
		return;
	end
	
	self.checkBounds();

	local m = self.getMaxValue();
	local c = self.getCurrentValue();
	local nSpacing = self.getSpacing();
	local nMaxSlotsPerRow = self.getMaxSlotsPerRow();
	
	if #(self.getSlotsData()) ~= m then
		self.clearSlotsData();

		-- Build slots
		for i = 1, m do
			local sIcon;
			if i > c then
				sIcon = stateicons[1].off[1];
			else
				sIcon = stateicons[1].on[1];
			end
			
			local nW = (i - 1) % nMaxSlotsPerRow;
			local nH = math.floor((i - 1) / nMaxSlotsPerRow);
			local nX = (nSpacing * nW) + math.floor(nSpacing / 2);
			local nY;
			if m > nMaxSlotsPerRow or allowsinglespacing then
				nY = (nSpacing * nH) + math.floor(nSpacing / 2);
			else
				nY = (nSpacing * nH) + nSpacing;
			end

			local wgt = addBitmapWidget({ icon = sIcon, position = "topleft", x = nX, y = nY });
			self.setSlotData(i, wgt);
		end
		
		if m > nMaxSlotsPerRow then
			setAnchoredWidth(nMaxSlotsPerRow * nSpacing);
			setAnchoredHeight((math.floor((m - 1) / nMaxSlotsPerRow) + 1) * nSpacing);
		else
			setAnchoredWidth(m * nSpacing);
			if allowsinglespacing then
				setAnchoredHeight(nSpacing);
			else
				setAnchoredHeight(nSpacing * 2);
			end
		end
	else
		for i = 1, m do
			local wgt = self.getSlotData(i);
			if wgt then
				if i > c then
					wgt.setBitmap(stateicons[1].off[1]);
				else
					wgt.setBitmap(stateicons[1].on[1]);
				end
			end
		end
	end
end

function adjustCounter(nAdj)
	local m = self.getMaxValue();
	local c = self.getCurrentValue() + nAdj;
	
	if c > m then
		self.setCurrentValue(m);
	elseif c < 0 then
		self.setCurrentValue(0);
	else
		self.setCurrentValue(c);
	end
end
function checkBounds()
	local m = self.getMaxValue();
	local c = self.getCurrentValue();
	
	if c > m then
		self.setCurrentValue(m);
	elseif c < 0 then
		self.setCurrentValue(0);
	end
end

local _sMaxNodeName = "";
function getMaxNode()
	return _sMaxNodeName;
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
function getMaxValue()
	local sPath = self.getMaxNode();
	if sPath ~= "" then
		return DB.getValue(sPath, 0);
	end
	return self.getLocalMax();
end
function setMaxValue(n)
	local sPath = self.getMaxNode();

	if not Session.IsHost then
		CrewManager.sendPlayerUpdateOobMsg(sPath, "number", n);
		return;
	end
	
	if sPath ~= "" then
		DB.setValue(sPath, "number", n);
	else
		self.setLocalMax(n);
	end
end

local _sCurrNodeName = "";
function getCurrNode()
	return _sCurrNodeName;
end
function setCurrNode(sNewCurrNodeName)
	if _sCurrNodeName ~= "" then
		DB.removeHandler(_sCurrNodeName, "onUpdate", self.update);
	end
	_sCurrNodeName = sNewCurrNodeName;
	if _sCurrNodeName ~= "" then
		DB.addHandler(_sCurrNodeName, "onUpdate", self.update);
	end
	self.updateSlots();
end
function getCurrentValue()
	local sPath = self.getCurrNode();
	if sPath ~= "" then
		return DB.getValue(sPath, 0);
	end
	return self.getLocalCurrent();
end
function setCurrentValue(n)
	local sPath = self.getCurrNode();

	if not Session.IsHost then
		CrewManager.sendPlayerUpdateOobMsg(sPath, "number", n);
		return;
	end

	if sPath ~= "" then
		DB.setValue(sPath, "number", n);
	else
		self.setLocalCurrent(n);
	end
end

--
--	MOUSE BEHAVIORS
--

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
	
	local m = self.getMaxValue();
	local c = self.getCurrentValue();
	local nSpacing = self.getSpacing();
	local nMaxSlotsPerRow = self.getMaxSlotsPerRow();

	local nClickH = math.floor(x / nSpacing) + 1;
	local nClickV;
	if m > nMaxSlotsPerRow then
		nClickV	= math.floor(y / nSpacing);
	else
		nClickV = 0;
	end
	local nClick = (nClickV * nMaxSlotsPerRow) + nClickH;

	if nClick > c then
		self.adjustCounter(1);
	else
		self.adjustCounter(-1);
	end

	return true;
end
