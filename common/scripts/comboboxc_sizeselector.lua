local tIndexes = {}

function onInit()
	super.onInit();

	local nCurValue = self.getControlValue();
	local nCurIndex = 1;
	for nIndex, tClock in ipairs(ClockManager.getClockSizes()) do
		local s = string.format(Interface.getString(tClock.sResource), tClock.nSize)
		self.add(s)
		tIndexes[s] = nIndex;
		
		if tClock.nSize == nCurValue then
			nCurIndex = nIndex;
		end
	end

	self.setListIndex(nCurIndex);
end

function onValueChanged()
	local nIndex = tIndexes[self.getSelectedValue()]
	if nIndex then
		local tData = ClockManager.getClockAtIndex(nIndex)
		if tData then
			self.setControlValue(tData.nSize)
		end
	end
end

function setControlValue(nValue)
	if not control or not control[1] then
		return;	
	end
	
	window[control[1]].setValue(nValue)
end

function getControlValue()
	if control and control[1] then
		return window[control[1]].getValue()
	end
end